#!/bin/bash
# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

depend() {
  need dbus
}

start() {
    echo "we don't actually have a way to start dhcp on 2.8 without connman, so we do nothing!"
}

stop() {
    echo "we don't actually have a way to start dhcp on 2.8 without connman, so we do nothing!"
}

restart() {
  stop
  sleep 2
  start
}
$1
