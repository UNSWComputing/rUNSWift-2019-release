cmake_minimum_required(VERSION 2.8.0 FATAL_ERROR)

set(CTC_DIR $ENV{RUNSWIFT_CHECKOUT_DIR}/softwares/ctc-linux64-atom-2.8.1.33)

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_VERSION 4)

set(CMAKE_SYSROOT ${CTC_DIR}/yocto-sdk/sysroots/core2-32-sbr-linux)


message("Toolchain 2.8")

add_definitions(-m32 -march=core2 -mtune=core2 -msse3 -mfpmath=sse --sysroot=${CTC_DIR}/yocto-sdk/sysroots/core2-32-sbr-linux --std=gnu++14)
set(CMAKE_C_COMPILER   ${CTC_DIR}/yocto-sdk/sysroots/x86_64-naoqisdk-linux/usr/bin/i686-sbr-linux/i686-sbr-linux-gcc)
set(CMAKE_FIND_ROOT_PATH
    ${CTC_DIR}/yocto-sdk
    ${CTC_DIR}
)
# we may actually want native programs, but i prefer we override that on a FIND_XXX basis
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
