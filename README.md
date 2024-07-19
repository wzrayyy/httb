# 🌐 HTTB
A simple HTTP framework written entirely in bash!

HTTB allows you to create a basic HTTP server using only bash scripts and the `socat` utility. It's utterly slow and useless, but if you _really_ want to build a web server in bash, then you have a tool for it!

# 🛠️ Setup
These instructions will help you get started with HTTB!

### 🐋 Docker
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

### 🖥️ Native
If you prefer to run HTTB natively on your system, ensure you have `bash` and `socat` installed. These tools are necessary for creating and managing TCP sockets.

### Debian/Linux Mint
To install `socat` on Debian-based systems:
```bash
sudo apt-get install socat
```

### Arch Linux
To install `socat` on Arch-based systems:
```bash
sudo pacman -S socat
```

### macOS
To install `socat` on macOS using Homebrew:
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

# ⚡ Benchmarking
To benchmark HTTB, use the Python module `Locust`. Configuration files are in the `benchmark` folder. Set up and run Locust with the following commands:

```sh
cd benchmark
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
locust
```
