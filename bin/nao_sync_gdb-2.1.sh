#!/bin/bash

REALPATH=`realpath "$0"`
BIN_DIR=`dirname "$REALPATH"`
source "$BIN_DIR/source.sh"

cd ${RUNSWIFT_CHECKOUT_DIR}
bin/nao_sync -b build-relwithdebinfo-$CTC_VERSION_2_1 -v 2.1 "$@"

echo -e "=================================================="
echo -e "If you are now looking to run gdb on the nao, run:"
echo
echo -e "\tnao_connect_gdb <nao ip>"
echo
echo -e "to connect, and then on the nao:"
echo
echo -e "\trunswift_gdbserver"
echo
echo -e "=================================================="
