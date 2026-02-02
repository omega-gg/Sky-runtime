#!/bin/sh
set -e
#==================================================================================================
#
#   Copyright (C) 2015-2020 Sky kit authors. <http://omega.gg/Sky>
#
#   Author: Benjamin Arnaud. <http://bunjee.me> <bunjee@omega.gg>
#
#   This file is part of the Sky kit runtime.
#
#   - GNU Lesser General Public License Usage:
#   This file may be used under the terms of the GNU Lesser General Public License version 3 as
#   published by the Free Software Foundation and appearing in the LICENSE.md file included in the
#   packaging of this file. Please review the following information to ensure the GNU Lesser
#   General Public License requirements will be met: https://www.gnu.org/licenses/lgpl.html.
#
#   - Private License Usage:
#   Sky kit licensees holding valid private licenses may use this file in accordance with the
#   private license agreement provided with the Software or, alternatively, in accordance with the
#   terms contained in written agreement between you and Sky kit authors. For further information
#   contact us at contact@omega.gg.
#
#==================================================================================================

#--------------------------------------------------------------------------------------------------
# Settings
#--------------------------------------------------------------------------------------------------

bin="$SKY_PATH_BIN"

name="Python"

version="3.14.2"

url="https://www.python.org/ftp/python/$version"

arguments="/quiet InstallAllUsers=1 PrependPath=1 Include_test=0"

#--------------------------------------------------------------------------------------------------
# Functions
#--------------------------------------------------------------------------------------------------

getPath()
{
    if [ $os = "windows" ]; then

        cygpath -w "$1"
    else
        echo "$1"
    fi
}

#--------------------------------------------------------------------------------------------------
# Syntax
#--------------------------------------------------------------------------------------------------

if [ $# != 1 ] || [ $# = 1 -a "$1" != "default" -a "$1" != "clean" ]; then

    echo "Usage: build <default | clean>"
    echo ""
    echo "example:"
    echo "    build default"

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# Clean
#--------------------------------------------------------------------------------------------------

if [ "$1" = "clean" ]; then

    echo "CLEANING"

    rm -rf "$bin/$name"

    exit 0
fi

#--------------------------------------------------------------------------------------------------
# Configuration
#--------------------------------------------------------------------------------------------------

case `uname` in
MINGW*)  os="windows";;
Darwin*) os="macOS";;
Linux*)  os="linux";;
*)       os="other";;
esac

if [ $os = "other" ]; then

    echo "build: Unsupported OS."

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# Clean
#--------------------------------------------------------------------------------------------------

cd "$bin"

rm -rf "$name"

#--------------------------------------------------------------------------------------------------
# Download
#--------------------------------------------------------------------------------------------------

mkdir -p "$name"

cd "$name"

if [ $os = "windows" ]; then

    arch="$(uname -m)"

    case "$arch" in
        x86_64|amd64)  setup="python-$version-embed-amd64.zip";;
        i686|x86)      setup="python-$version-embed-win32.zip";;
        aarch64|arm64) setup="python-$version-embed-arm64.zip";;
        *)             setup="python-$version-embed-amd64.zip";;
    esac

elif [ $os = "macOS" ]; then

    setup="python-$version-macos11.pkg"

else # [ $os = "linux" ]; then

    setup="Python-$version.tar.xz"
fi

url="$url/$setup"

curl --retry 3 -L -o "$setup" "$url"

#--------------------------------------------------------------------------------------------------
# Extract
#--------------------------------------------------------------------------------------------------

if [ $os = "windows" ]; then

    input=$(getPath "$PWD/$setup")

    output=$(getPath "$PWD")

    powershell -NoProfile -Command \
        "Expand-Archive -Path '$input' -DestinationPath '$output' -Force"

elif [ $os = "macOS" ]; then

    pkgutil --expand-full "$setup" temp

    mv temp/Python_Framework.pkg/Payload/Python.framework/Versions/Current/* .

    chmod +x "$python"

    rm -rf temp

else # [ $os = "linux" ]; then

    tar -xvf "$setup" --strip-components=1

    ./configure --prefix="$bin/$name" --enable-optimizations

    make -j$(nproc)

    make install
fi

rm "$setup"

#--------------------------------------------------------------------------------------------------
# Enable pip
#--------------------------------------------------------------------------------------------------

if [ $os = "windows" ]; then

    path="$bin/$name/python$(echo "$version" | tr -d . | cut -c1-3)._pth"

    if [ -f "$path" ]; then

        sed -i "s/^# *import site/import site/" "$path"
    fi
fi

if "$python" -m ensurepip --upgrade >/dev/null 2>&1; then

    exit 0
fi

script="get-pip.py"

curl --retry 3 -L -o "$script" "https://bootstrap.pypa.io/get-pip.py"

"$python" "$script" --no-warn-script-location

rm -f "$script"
