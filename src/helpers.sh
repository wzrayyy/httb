#!/bin/bash
# shellcheck disable=SC2015

http::_tempfile() {
    [ ! -d "/dev/shm" ] && TMP_FOLDER="/tmp" || TMP_FOLDER="/dev/shm"
    [ ! -d "${TMP_FOLDER}/httb-server" ] && mkdir "${TMP_FOLDER}/httb-server" || 
    mktemp -t 'httb-server.XXXXXXXXXXXX' -p "${TMP_FOLDER}/httb-server"
}
