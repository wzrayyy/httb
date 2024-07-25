#!/bin/bash

set -e
shopt -s globstar extglob dotglob

[ -n "${HTTP_GUARD__HTTP_SERVER_SH+x}" ] && return
export HTTP_GUARD__HTTP_SERVER_SH=''

: "${HTTP_SCRIPT_PATH:="$(dirname "$(readlink -e "${BASH_SOURCE[0]:-$0}")")"}"
readonly HTTP_SCRIPT_PATH

# shellcheck source=./constants.sh
. "${HTTP_SCRIPT_PATH}/constants.sh"
# shellcheck source=./helpers.sh
. "${HTTP_SCRIPT_PATH}/helpers.sh"
# shellcheck source=./request.sh
. "${HTTP_SCRIPT_PATH}/request.sh"
# shellcheck source=./response.sh
. "${HTTP_SCRIPT_PATH}/response.sh"
# shellcheck source=./markdown.sh
. "${HTTP_SCRIPT_PATH}/markdown.sh"

declare -A http__handlers=()
declare -A http__all_routes=()

# -- CONFIGURATION --

http::run() {
    if [[ "$1" = "run" ]]; then
        echo "Listening on ${HTTP_HOST:=${HTTP_DEFAULT_HOST}}:${HTTP_PORT:=${HTTP_DEFAULT_PORT}}"
        socat "TCP-LISTEN:${HTTP_PORT},bind=${HTTP_HOST},fork,reuseport" "EXEC:$(readlink -e "$0") parse"
    elif [[ "$1" = "parse" ]]; then
        http::_process_request
    else
        http::_cmd_help >&2
        exit 1
    fi
}

http::host() { export HTTP_HOST_NAME="$1"; }
http::bind() { export HTTP_HOST="${1:-${HTTP_DEFAULT_HOST}}"; export HTTP_PORT="${2:-${HTTP_DEFAULT_PORT}}"; }
http::markdown_base() { export HTTP_MARKDOWN_BASE="$1"; }

http::static_folder() {
    http__handlers["GET,$1/**"]="http::_static_file"
    http__all_routes["$1/**"]=1
    export HTTP_STATIC_FOLDER="$2";
}


http::route() {
    local _method
    while read -r _method; do
        # temp until all methods are suppoorted
        [[ -z "${HTTP_SUPPORTED_METHODS["${_method}"]}" ]] && echo "$1: Method ${_method} not implemented!" >&2 && exit 1
        http__handlers["$_method,$3"]="$1" # bad, skill issue
        http__all_routes["$3"]=1
    done <<< "${2/ /$'\n'}"
}


http::get() { http::route "$1" "GET" "$2"; }


http::_static_file() {
    local uri_path="${request_path#"${HTTP_REQUEST_GLOB%'**'}"}"
    local filename="${HTTP_STATIC_FOLDER}/${uri_path}"
    [[ -z "${uri_path}" || ! -f "${filename}" || "${filename}" == *".."* ]] && http::response 404 && return 1
    http::file "${filename}"
}


http::_process_request() {
    local -A request_headers response_headers
    local request_method request_path request_version connection_string

    http::_parse_headers || { http::response 405 && return 0; }
    # { [[ "${request_method}" != "GET" ]] && http::_parse_body; || { http::response 500 && return 0; }

    if [[ -n "${HTTP_HOST_NAME}" && "${HTTP_HOST_NAME}" != "${request_headers["Host"]%:*}" ]]; then
        http::response 404
        return 0
    fi

    : "${request_version}"

    http::_route_request
    [[ -z "${connection_string}" ]] && { http::response 500; return 0; }

    return 0
}

http::_cmd_help() {
    echo "USAGE:"
    echo "    $0 <run|parse>"
    echo
    echo "ARGUMENTS:"
    echo "    run            Run the server"
    echo "    parse          Parse http request from stdin and output to stdout"
}

