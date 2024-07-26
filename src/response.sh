#!/bin/bash

[ -n "${HTTP_GUARD__RESPONSE_SH+x}" ] && return
export HTTP_GUARD__RESPONSE_SH=''

: "${HTTP_SCRIPT_PATH:="$(dirname "$(readlink -e "${BASH_SOURCE[0]:-$0}")")"}"
readonly HTTP_SCRIPT_PATH

declare -A mime_types

while IFS=' ' read -r type ext; do
    mime_types["$ext"]="$type"
done < "$HTTP_SCRIPT_PATH/mime.types"


# $1 = status code
http::_response_base_headers() {
    connection_string="${HTTP_PROTOCOL_VERSION} $1 ${HTTP_METHOD_NAMES["$1"]}"
    : "${response_headers["Server"]:="${HTTP_SERVER_STRING}"}"
    : "${response_headers["Connection"]:="close"}"
    : "${response_headers["Date"]:="$(date -Ru)"}"
    : "${response_headers["Cache-control"]:="no-cache"}"
    : "${response_headers["Cache-control"]:="max-age=0"}"
}


# $1 = filename
http::_response_content_headers() {
    local type ext
    response_headers["Content-Length"]="$(wc -c "$1" | cut -d ' ' -f 1)"

    ext="$(cut -d '.' -f 2 <<< "$(basename "$1")")"
    : "${response_headers["Content-Type"]:="${mime_types["$ext"]:-"$(file -ib "$1")"}"}"
}


http::_output_response_headers() {
    echo "${connection_string}"
    for header_name in "${!response_headers[@]}"; do
	echo "${header_name}: ${response_headers[$header_name]}"
    done
    echo
}


# calle provides local -A response_headers
# $1 = status code
http::response() {
    local status_code status_page
    [[ -n "${HTTP_METHOD_NAMES["$1"]}" ]] && status_code="$1" || status_code="500"
    status_page="$(http::_status_code_page "${status_code}")"
    response_headers["Content-Type"]="text/html"
    http::_response_base_headers "${status_code}"
    http::_response_content_headers <(printf "%s" "${status_page}")
    http::_output_response_headers
    printf "%s" "${status_page}"
}


# calle provides local -A response_headers
# $1 = filename
http::file() {
    [[ ! -f "$1" ]] && { http::response 500 && return 1; }
    http::_response_base_headers "200"
    http::_response_content_headers "$1"
    http::_output_response_headers
    cat "$1"
}


# calle provides local -A response_headers
# $1 = url, $2 = status code (301/302, optional)
http::redirect() {
    local status_code="${2:-302}"
    [[ -z "$1" ]] && { http::response 500 && return 1; }
    http::_response_base_headers "${status_code}"
    response_headers["Location"]="$1"
    http::_output_response_headers
}

# calle provides local -A response_headers
# $1 = filename
http::html() { response_headers["Content-Type"]="text/html" http::file "$@"; }
