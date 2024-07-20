#!/bin/bash

set -e
set -m

install_gunicorn() {
    python3 -m venv .venv
    source .venv/bin/activate
    pip install gunicorn
}

declare -a reqs=('node' 'python3' 'go')
declare -A run_cmds=([8082]='go run test.go' [8083]='node test.js' [8084]='gunicorn -w 8 test:app -b localhost:8084' [8000]='python3 -m http.server' [8081]='bash ./test.sh run')

for package in "${reqs[@]}"; do
    command -v "${package}" >/dev/null || { echo "Error! ${package} is not installed on this system."; exit 1; }
done

command -v bombardier >/dev/null || go install github.com/codesenberg/bombardier@latest
command -v gunicorn >/dev/null || install_gunicorn >/dev/null

for port in "${!run_cmds[@]}"; do
    echo "Running: ${run_cmds[$port]}"
    ${run_cmds[$port]} >/dev/null 2>&1 & pid="$!"
    sleep 0.5
    bombardier -d 30s http://127.0.0.1:"$port"
    kill -TERM -- -"$pid"
done
