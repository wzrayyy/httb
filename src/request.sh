#!/bin/bash

[ -n "${HTTP_GUARD__REQUEST_SH+x}" ] && return
export HTTP_GUARD__REQUEST_SH=''

http::_parse_headers() {
    read -r request_method request_path request_version

    while read -r header_; do
        [[ -z "${header_/$'\r'/}" ]] && break
        local h_name h_value
        IFS=: read -r h_name h_value <<< "${header_/': '/:}"
        request_headers["${h_name}"]="${h_value}"
    done
}

http::_parse_body() { cat - >/dev/null; } # TODO

http::_route_request() {
    [[ -z "${HTTP_SUPPORTED_METHODS[${request_method}]}" ]] && { http::response 501; return 1; }
    local glob_endpoint handler path_found

    for glob_endpoint in "${!http__all_routes[@]}"; do # FIXME O(n)
        # shellcheck disable=SC2053
        if [[ "${request_path}" == ${glob_endpoint} ]]; then
            path_found=1
            break
        fi
    done

    handler="${http__handlers["$request_method,$glob_endpoint"]}"

    if [[ -z "${path_found}" ]]; then
        http::response 404; return 1
    elif [[ -z "${handler}" ]]; then
        http::response 405; return 1
    else
        "${handler}"
    fi
}
