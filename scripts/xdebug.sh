#!/bin/bash

PHP="/usr/bin/php"

extfile="/usr/lib/php/modules/xdebug.so"
idekey="xdbg"
remote_port=9000
remote_host="127.0.0.1"

$PHP \
    -d "zend_extension=${extfile}" \
    -d "xdebug.idekey=${idekey:-xdbg}" \
    -d "xdebug.remote_enable=1" \
    -d "xdebug.remote_connect_back=1" \
    -d "xdebug.remote_autostart=1" \
    -d "xdebug.remote_port=${remote_port:-9000}" \
    -d "xdebug.remote_host=${remote_host:-127.0.0.1}" \
    -d "xdebug.remote_handler=dbgp" \
    "$@"
