#!/bin/bash

REALPATH=`realpath "$0"`
BIN_DIR=`dirname "$REALPATH"`
source "$BIN_DIR/source.sh"

myecho This script downloads and installs the required software to run simswift.

cd "$RUNSWIFT_CHECKOUT_DIR/softwares"

# Check operating system
if [[ "$OSTYPE" != "linux-gnu" ]]; then
	myerror "simswift is only supported on Linux!"
	exit
fi

# Get machine type (32bit / 64bit)
export MACHINE_TYPE=$(getmachinetype)

# Download prerequisites
myecho "Downloading/installing simulation software pre-requisites..."
aptinstall g++ subversion cmake libfreetype6-dev libode-dev libsdl1.2-dev ruby ruby-dev libdevil-dev libboost-dev libboost-thread-dev libboost-regex-dev libboost-system-dev qt4-default libqt4-opengl-dev # requirements for simspark
aptinstall gcc-multilib g++-multilib
aptinstall default-jdk default-jre
aptinstall python2.7

# Git clone modified roboviz / simspark
myecho "Cloning SimSpark and RoboViz (rUNSWift modification)"

if [[ ! -d roboviz ]]; then
	myecho "Shallow cloning modified roboviz"
	git clone --depth=1 https://github.com/ijnek/RoboViz.git roboviz
fi

if [[ ! -d simspark ]]; then
	myecho "Shallow cloning modified simspark"
	git clone --depth=1 https://gitlab.com/ijnek/SimSpark.git simspark
fi

# Install simspark(spark and rcssserver3d)
SPARK_INSTALL_PATH="$RUNSWIFT_CHECKOUT_DIR"/softwares/simspark/spark/installed
RCSSSERVER3D_INSTALL_PATH="$RUNSWIFT_CHECKOUT_DIR"/softwares/simspark/rcssserver3d/installed
myecho "Building and installing modified simspark..."
myecho "Building simspark - spark"
cd simspark/spark
mkdir -p build
cd build
cmake -DCMAKE_INSTALL_PREFIX="$SPARK_INSTALL_PATH" \
      -DCMAKE_INSTALL_RPATH="$SPARK_INSTALL_PATH"/lib/simspark \
      -DRCSSSERVER3D_INSTALL_PATH="$RCSSSERVER3D_INSTALL_PATH" \
      ..
make install
cd ../../../

myecho "Building simspark - rcssserver3d"
cd simspark/rcssserver3d
mkdir -p build
cd build
cmake -DCMAKE_INSTALL_PREFIX=$RCSSSERVER3D_INSTALL_PATH -DCMAKE_PREFIX_PATH="$SPARK_INSTALL_PATH" ..
make install
cd ../../../

# Install roboviz
myecho "Building and installing modified roboviz..."
if [[ ${MACHINE_TYPE} == 'x86_64' ]]; then
	./roboviz/scripts/build-linux64.sh  
else
	./roboviz/scripts/build-linux32.sh  
fi

# Prepare system to use simulation build

cd $RUNSWIFT_CHECKOUT_DIR/ctc

myecho "Preparing system for use of simulation build..."

# Apply CTC patch
myecho "Downloading and installing CTC patch..."
if [[ ! -f ctc_patch.tar.gz ]]; then
    if ! wget http://runswift2.cse.unsw.edu.au/simulation/ctc_patch.tar.gz; then
        rsync -aP runswift@runswift2.cse.unsw.edu.au:/var/www/html/simulation/ctc_patch.tar.gz .
    fi
fi
# ctc_patch.tar.gz/ctc_patch/sysroot_legacy => ./sysroot_legacy
tar -zxf ctc_patch.tar.gz ctc_patch/sysroot_legacy --strip-components=1
# Delete old files
rm -f sysroot_legacy/usr/lib/python2.7/random.py[co]

# Fix python bug - https://github.com/pypa/virtualenv/issues/410
myecho "Fixing ubuntu python bug..."
if [[ ! -L /usr/lib/python2.7/_sysconfigdata_nd.py ]]; then
	sudo ln -s /usr/lib/python2.7/plat-*/_sysconfigdata_nd.py /usr/lib/python2.7/
fi


# Finish
myecho "All done. Please close all shells (or run \"source ~/.runswift.bash\"). Upon opening a new shell, you can start roboviz by typing 'roboviz.sh' or rcssserver by typing 'rcssserver3d'."
