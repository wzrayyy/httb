# 🌐 HTTB
A simple HTTP framework written entirely in bash!

HTTB allows you to create a basic HTTP server using only bash scripts and the `socat` utility. It's utterly slow and useless, but if you _really_ want to build a web server in bash, then you have a tool for it!

# 🛠️ Setup
These instructions will help you get started with HTTB!

## 🐋 Docker
I would heavily recommend **not** running this on bare metal, as safety was (and still is) my last concern at the moment. This repository contains an example `Dockerfile` and `docker-compose.yml` files that can get you started.

To get started with Docker:

1. **Clone the repository**:
    ```sh
    git clone https://github.com/wzrayyy/httb.git
    cd httb
    ```

2. **Build and run the Docker image**:
    ```sh
    docker compose up --build
    ```

## 🖥️ Native
If you prefer to run HTTB natively on your system, ensure you have `bash socat file` installed. These tools are necessary for running this server.

### Debian/Linux Mint
To install dependencies on Debian-based systems:
```bash
sudo apt-get install socat
```

### Arch Linux
To install dependencies on Arch-based systems:
```bash
sudo pacman -S socat
```

### macOS
To install dependencies on macOS using Homebrew:
```bash
brew install socat
```

### Windows
On Windows, you can use WSL (Windows Subsystem for Linux) to run a Linux distribution and follow the instructions for your preferred distro.

# 📋 Usage
Here is a sample script to get you started with HTTB:

```sh
#!/bin/bash

# source the main library file
. http_server.sh

# set static folder (optional)
http::static_folder "/static" "./static"

# specify bind location (optional, default is 127.0.0.1:8081)
http::bind "0.0.0.0" "80"

server::root() {
    http::html "html/index.html"
} && http::get server::file "/"

server::easter_egg() {
    http::response 239
} && http::get server::file '/easter_egg'

server::file() {
    http::file "./main.sh"
    # alternatively you can use
    http::raw_file < ./main.sh
} && http::route server::file "GET" '/main'

server::post_form() {
    # TODO
} && http::post server::post_form '/form'

# run the server (note that you **have** to pass "$@" to it)
http::run "$@"
```

# ⚡ Benchmarks
It's... bad 🥲

All benchmarks were conducted on an i7-1360P laptop with 16GB of RAM using the tool codesenberg/bombardier. The benchmark folder in the repository contains all the source files used for benchmarking, along with a run.sh script to automate the benchmarking process. Here are the detailed results:

### python3 -m http.server
```
Statistics        Avg      Stdev        Max
  Reqs/sec      1501.94     297.64    3249.71
  Latency       84.75ms   458.09ms     15.47s
  HTTP codes:
    1xx - 0, 2xx - 45205, 3xx - 0, 4xx - 0, 5xx - 0
    others - 0
  Throughput:     0.86MB/s
```

### Flask w/ guvicorn
```
Statistics        Avg      Stdev        Max
  Reqs/sec     23355.06    8909.87   36359.07
  Latency        5.35ms     2.73ms   121.66ms
  HTTP codes:
    1xx - 0, 2xx - 700131, 3xx - 0, 4xx - 0, 5xx - 0
    others - 0
  Throughput:     4.81MB/s
```

### HTTB
```
Statistics        Avg      Stdev        Max
  Reqs/sec      1287.59     226.72    2057.52
  Latency       96.81ms   168.72ms      3.17s
  HTTP codes:
    1xx - 0, 2xx - 13004, 3xx - 0, 4xx - 0, 5xx - 0
    others - 0
  Throughput:   304.04KB/s
```

### Node.js
```
Statistics        Avg      Stdev        Max
  Reqs/sec     91833.85    4907.33   97671.88
  Latency        1.36ms   119.26us    17.27ms
  HTTP codes:
    1xx - 0, 2xx - 2754740, 3xx - 0, 4xx - 0, 5xx - 0
    others - 0
  Throughput:    19.09MB/s
```

### Golang
```
Statistics        Avg      Stdev        Max
  Reqs/sec    304523.14   32166.94  453253.21
  Latency      407.73us   182.95us    91.07ms
  HTTP codes:
    1xx - 0, 2xx - 9138757, 3xx - 0, 4xx - 0, 5xx - 0
    others - 0
  Throughput:    52.29MB/s
```
