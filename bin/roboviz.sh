#!/bin/bash

REALPATH=`realpath "$0"`
BIN_DIR=`dirname "$REALPATH"`
source "$BIN_DIR/source.sh"

# Get machine type (32bit / 64bit)
export MACHINE_TYPE=$(getmachinetype)
if [[ ${MACHINE_TYPE} == 'x86_64' ]]; then
    # 64-bit
    ROBOVIZ_PATH="$RUNSWIFT_CHECKOUT_DIR/softwares/roboviz/bin/linux-amd64/"
else
    # 32-bit
    ROBOVIZ_PATH="$RUNSWIFT_CHECKOUT_DIR/softwares/roboviz/bin/linux-i586/"
fi
"$ROBOVIZ_PATH/roboviz.sh" "$@"
