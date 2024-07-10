#!/bin/bash

set -e
shopt -s globstar extglob dotglob

# readonly HTTP_SCRIPT_PATH="$(dirname "$(readlink -e "${BASH_SOURCE[0]:-$0}")")"
# . "${SCRIPT_PATH}/mock_tcp_server.sh"
# . "${SCRIPT_PATH}/constants.sh"

. "./lib/constants.sh" && . "./lib/helpers.sh"


declare -A http__handlers=()
declare -A http__all_routes=()

# -- CONFIGURATION --

http::host() { export HTTP_HOST_NAME="$1"; }
http::bind() { export HTTP_HOST="${1:-127.0.0.1}"; export HTTP_PORT="${2:-8081}"; }
http::markdown_base() { export HTTP_MARKDOWN_BASE="$1"; }

http::static_folder() {
    http__handlers["GET,$1/**"]="http::_static_file"
    http__all_routes["$1/**"]=1
    export HTTP_STATIC_FOLDER="$2";
}

# -- PUBLIC METHODS --

http::route() {
    local _method
    while read -r _method; do
        # temp until all methods are suppoorted
        [[ -z "${HTTP_SUPPORTED_METHODS[${_method}]}" ]] && echo "$1: Method ${_method} not implemented!" >&2 && exit 1
        http__handlers["$_method,$3"]="$1"
        http__all_routes["$3"]=1
    done <<< "${2/ /$'\n'}"
}

http::get() { http::route "$1" "GET" "$2"; }

# -- REQUEST PROCESSING --

http::_parse_headers() { 
    local -n _h=$1 _m=$2 _p=$3 _v=$4

    read -r header_first_
    read -r _m _p _v <<<"$header_first_"

    while read -r header_; do
        [[ -z "${header_/$'\r'/}" ]] && break
        local h_name h_value
        IFS=: read -r h_name h_value <<< "${header_/': '/:}"
        _h["${h_name}"]="${h_value}"
    done
}

http::_parse_body() { :; } # TODO

http::_route_request() {
    [[ -z "${HTTP_SUPPORTED_METHODS[${HTTP_REQUEST_METHOD}]}" ]] && http::response 501 && return 1
    local glob_endpoint handler path_found

    for glob_endpoint in "${!http__all_routes[@]}"; do # FIXME
        # shellcheck disable=SC2053
        if [[ "${HTTP_REQUEST_PATH}" == ${glob_endpoint} ]]; then 
            declare -rx HTTP_REQUEST_GLOB="${glob_endpoint}"
            path_found=1
            break
        fi
    done

    handler=${http__handlers["$HTTP_REQUEST_METHOD,$glob_endpoint"]}

    if [[ -z "${path_found}" ]]; then
        http::response 404; return 1
    elif [[ -z "${handler}" ]]; then
        http::response 405; return 1
    else
        ${handler}
    fi

}

# -- RESPONSE PROCESSING --

http::_response_base_headers() {
    printf "%s %d %s\n" "${HTTP_PROTOCOL_VERSION}" "$1" "${HTTP_METHOD_NAMES["$1"]}"
    cat <<-EOS
		Server: ${HTTP_SERVER_STRING}
		Connection: close
		Date: $(date -Ru)
		Cache-control: no-cache
		Cache-control: max-age=0
	EOS
}

http::_response_content_headers() {
    echo "Content-Length: $(wc -c "$1" | cut -d ' ' -f 1)"
    echo "Content-Type: ${HTTP_RESPONSE_CONTENT_TYPE:="$(file -ib "$1")"}"
    echo
}

http::_response_content() {
    local -r content_file="$(http::_ramfile)" # TODO mb adapt to mkfifo pipes
    cat - > "${content_file}"

    http::_response_content_headers "${content_file}"

    cat "${content_file}"
    rm -f "${content_file}"
}

http::_static_file() {
    local uri_path="${HTTP_REQUEST_PATH#"${HTTP_REQUEST_GLOB%'**'}"}"
    local filename="${HTTP_STATIC_FOLDER}/${uri_path}"
    [[ -z "${uri_path}" || ! -f "${filename}" ]] && http::response 404 && return 1
    http::file "${filename}"
}

http::response() { 
    local status_code page
    [[ -n "${HTTP_METHOD_NAMES["$1"]}" ]] && status_code="$1" || status_code="500"
    page="$(http::_status_code_page "${status_code}")"
    http::_response_base_headers "${status_code}"
    http::_response_content <<< "${page}"
}

http::file() { 
    [[ ! -f "$1" ]] && http::response 500 && return 1
    http::_response_base_headers "200"
    http::_response_content < "$1"
}

http::html() { HTTP_RESPONSE_CONTENT_TYPE="text/html" http::file "$@"; }

http::format_markdown() { :; } # TODO

# -- COMMAND LINE LOGIC --

http::_process_request() {
    declare -Ax HTTP_REQUEST_HEADERS
    export HTTP_REQUEST_METHOD HTTP_REQUEST_PATH HTTP_REQUEST_VERSION HTTP_REQUEST_BODY

    http::_parse_headers HTTP_REQUEST_HEADERS HTTP_REQUEST_METHOD HTTP_REQUEST_PATH HTTP_REQUEST_VERSION || return 1
    http::_parse_body HTTP_REQUEST_BODY || return 1
    if [[ -n "${HTTP_HOST_NAME}" && "${HTTP_HOST_NAME}" != "${HTTP_REQUEST_HEADERS["Host"]%:*}" ]]; then
        http::response 404
        return
    fi
    http::_route_request
    return 0
}

http::_cmd_help() {
    echo "USAGE:"
    echo "    $0 <run|parse> [OPTIONS]"
    echo
    echo "ARGUMENTS:"
    echo "    run            Run the server"
    echo "    parse          Parse http request from stdin and output to stdout"
}

http::run() {
    if [[ "$1" = "run" ]]; then
        echo "Listening on ${HTTP_HOST}:${HTTP_PORT}"
        socat "TCP-LISTEN:${HTTP_PORT},bind=${HTTP_HOST},fork,reuseport" "EXEC:$(readlink -e "$0") parse"
    elif [[ "$1" = "parse" ]]; then
        http::_process_request
    else
        http::_cmd_help >&2
        exit 1
    fi
}
