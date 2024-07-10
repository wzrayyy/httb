#!/bin/bash

http::_ramfile() { # TODO use tempdir instead of files
    mktemp -t 'httb-server.XXXXXXXXXXXX' -p "/dev/shm"
}
