#!/bin/bash
MAX_CONNECTIONS=1

_workers_=()

tcp::worker_() {
    local socket_input socket_output request src_address
    local host="${1:-0.0.0.0}"
    local port="${2:-8081}"
    local delimiter=""
    local delimiter_placeholder='DELIMTIER_PLACEHOLDER'

    exec {socket_input}<> <(:)
    exec {socket_output}<> <(:)

    # { nc -lknv -s "${host}" -p "${port}" > >( stdbuf -o0 sed "s/$delimiter/$delimiter_placeholder/g" ) 2> >( stdbuf -o0 sed "/Listening on.*/d;s/Connection received on /$delimiter/" >&2; ) ; } <&$socket_input >&$socket_output 2>&1 &
    {
        socat "TCP-LISTEN:${host:-80},bind=${port:-127.0.0.1},fork,reuseport"  \
        > >( stdbuf -o0 sed "s/$delimiter/$delimiter_placeholder/g" ) \
        2> >( stdbuf -o0 sed "/Listening on.*/d;s/Connection received on /$delimiter/" >&2; ) ;
    } <&$socket_input >&$socket_output 2>&1 &

    echo "listenning"

    while :; do
        read -d "$delimiter" -r -u $socket_output request
        read -r -u $socket_output src_address; src_address="${src_address/ /:}"

        printf -- '--- NEW REQUEST ---\n'
        echo "$request"
        printf -- '--- SOURCE ADDR ---\n'
        echo "$src_address"
        printf -- '--- END REQUEST ---\n\n\n'

        printf "%s\n\n%s" "$(cat response.txt)" "$(cat index.html)" >&$socket_input # main logic
    done

    exec {socket_input}<&-
    exec {socket_output}<&-
}


tcp::listen() {
    for _ in $(seq $MAX_CONNECTIONS); do
        tcp::worker_ "$1" "$2" & _workers_+=("$!")
    done
    wait
}

tcp::listen "$@"
