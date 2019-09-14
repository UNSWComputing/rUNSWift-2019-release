#!/bin/bash

# jayen isn't a fan of `sudo pip install`, so please use `aptinstall` where
# possible.  see flake8 below for an example.  if you absolutely must use `sudo
# pip install`, make a function like `aptinstall`

# TODO: move non-build stuff out of here (e.g., ssh, game controller, pip for nao_sync -s)

REALPATH=`realpath "$0"`
BIN_DIR=`dirname "$REALPATH"`
source "$BIN_DIR/source.sh"

setupdocker
aptinstall git

# Set up git
cat << USER_CONFIG
If the user info is incorrect, please configure it like:
  git config user.name Jayen
  git config user.email jayen@cse.unsw.edu.au
USER_CONFIG
cd "$RUNSWIFT_CHECKOUT_DIR"
echo Your user name: $(git config user.name)
echo Your email: $(git config user.email)

if [[ ! -f /etc/apt/sources.list.d/github_git-lfs.list ]]; then # 2.3.4 in ubuntu 18.04 is BROKEN
  aptinstall curl
  curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
fi
aptinstall git-lfs
git lfs pull

# Set up ssh_config
mkdir -p ~/.ssh
chmod 700 ~/.ssh
[[ -f ~/.ssh/config ]] || touch ~/.ssh/config
chmod 600 ~/.ssh/config
# it's ok if old ones are there.  ssh seems to use rules in
# both.  if both have the same rule, the first takes precedence
if ! grep -q "Host ${!robots[*]}" ~/.ssh/config ; then (
  echo
  echo "Host ${!robots[*]}"
  echo "  Hostname %h.local"
  echo "  CheckHostIP no"
  echo "  User nao"
  echo "  StrictHostKeyChecking no"
) >> ~/.ssh/config
fi

setupbash

aptinstall wget unzip
cd "$RUNSWIFT_CHECKOUT_DIR"
bin/gamecontroller_install.sh

# SSH keys
aptinstall openssh-client
ssh-keygen -l -f ~/.ssh/id_rsa.pub &> /dev/null || ssh-keygen -f ~/.ssh/id_rsa -N '' -q
if ! grep -qf ~/.ssh/id_rsa.pub "$RUNSWIFT_CHECKOUT_DIR"/image/home/nao/.ssh/authorized_keys; then
  echo >> "$RUNSWIFT_CHECKOUT_DIR"/image/home/nao/.ssh/authorized_keys
  echo "# $(git config user.name)'s key" >> "$RUNSWIFT_CHECKOUT_DIR"/image/home/nao/.ssh/authorized_keys
  cat ~/.ssh/id_rsa.pub >> "$RUNSWIFT_CHECKOUT_DIR"/image/home/nao/.ssh/authorized_keys
fi

# Set up git hook linter
aptinstall python-flake8
if ! grep -q "runswift_test.sh" "$RUNSWIFT_CHECKOUT_DIR"/.git/hooks/pre-commit &> /dev/null; then
  myecho "Installing git hook to catch coding style violations"
  mkdir -p "${RUNSWIFT_CHECKOUT_DIR}/.git/hooks/"
  echo "${RUNSWIFT_CHECKOUT_DIR}/bin/runswift_test.sh --python-files-only" >> "$RUNSWIFT_CHECKOUT_DIR"/.git/hooks/pre-commit
  chmod u+x "$RUNSWIFT_CHECKOUT_DIR"/.git/hooks/pre-commit
fi

# Set up local copy of pip packages needed on robots
aptinstall python-pip
if [[ ! -f "$RUNSWIFT_CHECKOUT_DIR/softwares/pip/msgpack-0.6.1-cp27-cp27m-manylinux1_i686.whl" ]]; then
  pip download msgpack --dest "$RUNSWIFT_CHECKOUT_DIR/softwares/pip" --platform manylinux1_i686 --python-version 27 --implementation cp --abi cp27m --only-binary=:all:
fi

########### Toolchain ##########
setupctc

# Create nao symlink
myecho "Creating /home/nao symlink..."
if [[ ! -L /home/nao ]]; then
    sudo ln -s $RUNSWIFT_CHECKOUT_DIR/image/home/nao /home/
fi
# for nao os 2.8
# use flite because naoqi waits 10 mins before loading ALTextToSpeech
(
    # change working directory
    cd "$RUNSWIFT_CHECKOUT_DIR/softwares"
    # get it
    [[ -d flite ]] || git clone https://github.com/festvox/flite
    # change dir
    cd flite
    # setup to compile for nao
    CCACHE_PATH=
    source "$RUNSWIFT_CHECKOUT_DIR/ctc/ctc-linux64-atom-2.8.1.33/yocto-sdk/environment-setup-core2-32-sbr-linux"
    # set everything up for running from /home/nao
    [[ -f config.status ]] || ./configure --prefix=/home/nao/2.8
    # compile
    [[ -f bin/flite_cmu_us_slt ]] || make
    # get the voices
    [[ -f voices/cmu_us_slt.flitevox ]] || make get_voices
    # install to /home/nao on your laptop, which should be a symlink to $RUNSWIFT_CHECKOUT_DIR/image
    make install
)

############ Building ###########
aptinstall cmake patchelf
NPROC=$(nproc)
myecho Generating Makefiles and doing the initial build
for CTC_VERSION in "${CTC_VERSIONS[@]}"; do
    TOOLCHAIN_FILE="$RUNSWIFT_CHECKOUT_DIR"/toolchain-${CTC_VERSION%.*.*}.cmake
    for i in release relwithdebinfo; do
        cd "$RUNSWIFT_CHECKOUT_DIR"
        BUILD_DIR=build-$i-$CTC_VERSION
        mkdir -p $BUILD_DIR
        cd $(readlink -f $BUILD_DIR)
        echo "CMAKE!!!"
        cmake  --debug-trycompile "$RUNSWIFT_CHECKOUT_DIR" -DBoost_NO_BOOST_CMAKE=1 -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_FILE} -DCMAKE_BUILD_TYPE=$i -DCMAKE_MAKE_PROGRAM=make
        if [[ ${CTC_VERSION} = ${CTC_VERSION_2_1} ]]; then
            # run cmake again to switch sysroot from legacy to 2.1 (for qt apps like offnao)
            cmake .
        fi
    done
done
# Build!
#only builds for one CTC.  change it by changing CTC_VERSIONS
for i in release relwithdebinfo; do
    cd "$RUNSWIFT_CHECKOUT_DIR"
    # we used to not have version numbers in build dirs, then aldebaran released ctc 2.8 without support for old robots
    if [[ -e build-$i ]] && [[ ! -L build-$i ]]; then
        mv build-$i build-$i.old
    fi
    ln -sfn build-$i-$CTC_VERSION build-$i
    cd $(readlink -f build-$i)
    echo "MAKE!!!"
    make
done

# Adding the offnao patch for ubuntu versions 16.04 and above
#   s3 seems to have a weird issue with --content-disposition and
#   either of --continue or --timestamping, so we explicitly disable it
#   https://github.com/UNSWComputing/rUNSWift/pull/1861#discussion_r263960572
wget --content-disposition=off https://github.com/UNSWComputing/rUNSWift-assets/releases/download/v2017.1/libGL.so.1 --directory-prefix=$RUNSWIFT_CHECKOUT_DIR/ctc/sysroot_legacy/usr/lib


echo
echo All done! To build, type nao_build or nao_build_gdb to respectively compile the release or debug versions
echo

# Finish
myecho Please close all shells.  Only new shells will have RUNSWIFT_CHECKOUT_DIR set to $RUNSWIFT_CHECKOUT_DIR
myecho 'Alternatively, type `source ~/.runswift.bash` in existing shells.'
echo
