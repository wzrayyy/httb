#!/bin/bash

[ -n "${HTTP_GUARD__HELPERS_SH+x}" ] && return
export HTTP_GUARD__HELPERS_SH=''

http::_tempfile() {
    [ ! -d "/dev/shm" ] && TMP_FOLDER="/tmp" || TMP_FOLDER="/dev/shm"
    # shellcheck disable=SC2015
    [ ! -d "${TMP_FOLDER}/httb-server" ] && mkdir "${TMP_FOLDER}/httb-server" ||
    mktemp -t 'httb-server.XXXXXXXXXXXX' -p "${TMP_FOLDER}/httb-server"
}
