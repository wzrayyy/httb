#!/bin/bash

# shellcheck disable=SC1090
. lib/http_server.sh
. routes/*.sh

http::static_folder "/static" "./static"

root() {
    http::html "html/index.html"
} && http::get root "/"


main() {
    http::file "./main.sh"
} && http::route main "GET" '/main'


http::run "$@"
