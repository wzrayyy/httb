#!/bin/bash

[ -n "${HTTP_GUARD__MARKDOWN_SH+x}" ] && return
export HTTP_GUARD__MARKDOWN_SH=''


http::_convert_to_md() {
    local -a pandoc_options=(
	'--from=gfm+tex_math_dollars '
	'--to=html'
	'--mathjax'
	'--toc'
	"--template=${HTTP_MARKDOWN_BASE:-'default.html5'}"
    )
    pandoc "${pandoc_options[@]}" "$1"
}

http::md() {
    [[ ! -f "$1" ]] && { http::response 500 && return 1; }
    markdown="$(http::_convert_to_md "$1")"
    http::_response_base_headers "200"
    response_headers["Content-Type"]="text/html"
    http::_response_content_headers <(printf "%s" "$markdown")
    http::_output_response_headers
    printf "%s" "$markdown"
}
