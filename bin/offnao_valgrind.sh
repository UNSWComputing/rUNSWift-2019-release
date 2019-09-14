#!/bin/bash
[[ -d ${RUNSWIFT_CHECKOUT_DIR}/build-valgrind ]] || build_setup_valgrind.sh
${RUNSWIFT_CHECKOUT_DIR}/build-valgrind/utils/offnao/voffnao "$@"
