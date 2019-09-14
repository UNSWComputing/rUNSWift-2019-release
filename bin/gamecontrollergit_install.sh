#!/bin/bash
set -e
set -u

package=ant
if ! dpkg --status $package >& /dev/null; then
    echo installing $package
    # need to pipe to /dev/null for dpkg
    sudo apt-get -qq install $package > /dev/null
fi

# Idempotently download and install game controller and TCM
export GAME_CONTROLLER=GameControllerGit
cd ${RUNSWIFT_CHECKOUT_DIR}/softwares

# Gamecontrollermaster is downloaded from B-Human's repository
if [ -d $GAME_CONTROLLER ]; then
    echo "GameControllerGit already installed - skipping"
else
    mkdir ${GAME_CONTROLLER}
    echo "Cloning ${GAME_CONTROLLER} from BHuman's repository"
    git clone https://github.com/bhuman/GameController.git ${GAME_CONTROLLER}
    cd  ${GAME_CONTROLLER}
    ant
fi
