. ../src/http_server.sh

http::bind "127.0.0.1" "8081"

main() {
    http::response 200
} && http::get main "/"

http::run "$@"
