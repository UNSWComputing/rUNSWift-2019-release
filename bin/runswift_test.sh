#!/usr/bin/env bash


# Also make it work in SourceTree =/
# https://community.atlassian.com/t5/Bitbucket-questions/SourceTree-Hook-failing-because-paths-don-t-seem-to-be-set/qaq-p/274792
export PATH=/usr/local/bin:$PATH


cd ${RUNSWIFT_CHECKOUT_DIR}
PYTHON_FILES_WC=$(git status -s | grep ".py" | wc -l | tr -d '[:space:]')
if [ "$PYTHON_FILES_WC" -ne "0" ] || [ "$1" != "--python-files-only" ]; then
    python2 -m flake8 --version >/dev/null 2>&1 || {
        echo >&2 "You must install flake8 for python2, but it's not installed. Try:"
        echo >&2 "    sudo apt install python-flake8"
        echo >&2 "Or follow - http://flake8.pycqa.org/en/latest/"
        exit 1;
    }
    python2 -m flake8 --max-line-length=120 image/
    RETURN_VALUE="$?"

    # Give pretty feedback to developer
    if [ "${RETURN_VALUE}" == "0" ]; then
        echo -e "\033[0;32mWell done, no python2 flake8 warnings found :D\033[0m"
    else
        echo -e "\033[0;31mPlease resolve the python2 flake8 warnings ^_^\033[0m"
        exit 1;
    fi

# else
#    echo "No python changes."
fi
