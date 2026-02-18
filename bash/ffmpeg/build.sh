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

python="${SKY_PATH_PYTHON:-$SKY_PATH_BIN/python}"

name="ffmpeg"

version="N-122611-g7e9fe341df"

version_mac="8.0.1"

url="https://github.com/BtbN/FFmpeg-Builds/releases/download/autobuild-2026-02-02-13-01/ffmpeg-$version"

url_mac="https://evermeet.cx/ffmpeg"

#--------------------------------------------------------------------------------------------------
# Extract
#--------------------------------------------------------------------------------------------------

extract()
{
    python - <<EOF
import os, zipfile, sys

zip_path = os.path.abspath("$1")

dst = os.path.abspath(".")

with zipfile.ZipFile(zip_path, "r") as z:
    z.extractall(dst)

print("Extracted to:", dst)
EOF

    rm "$1"
}

extract_mac()
{
    curl --retry 3 -L -o "archive.zip" "$1"

    extract "archive.zip"
}

move_bin()
{
    folder=$(find . -maxdepth 3 -type d -name bin | head -n 1)

    if [ -z "$folder" ]; then

        echo "build: Cannot find a bin directory in the extracted archive."

        exit 1
    fi

    mv "$folder"/* .
}

#--------------------------------------------------------------------------------------------------
# Syntax
#--------------------------------------------------------------------------------------------------

if [ $# != 1 ] || [ $# = 1 -a "$1" != "default" ]; then

    echo "Usage: build <default>"
    echo ""
    echo "example:"
    echo "    build default"

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# Clean
#--------------------------------------------------------------------------------------------------

cd "$bin"

rm -rf "$name"

#--------------------------------------------------------------------------------------------------
# Environment
#--------------------------------------------------------------------------------------------------

case `uname` in
    MINGW*|MSYS*|CYGWIN*) export PATH="$python:$PATH";;
    *)                    export PATH="$python/bin:$PATH";;
esac

#--------------------------------------------------------------------------------------------------
# Download
#--------------------------------------------------------------------------------------------------

mkdir -p "$name"

cd "$name"

case `uname` in
    MINGW*|MSYS*|CYGWIN*) os="windows";;
    Darwin*)              os="macos";;
    Linux*)               os="linux";;
    *)                    os="other";;
esac

if [ $os = "other" ]; then

    echo "build: Unsupported OS."

    exit 1
fi

case `uname -m` in
    x86_64|amd64) arch="x86_64";;
    *)            arch="other";;
esac

#--------------------------------------------------------------------------------------------------
# Download
#--------------------------------------------------------------------------------------------------

if [ $os = "windows" ]; then

    archive="archive.zip"

    url="$url-win64-gpl-shared.zip"

    curl --retry 3 -L -o "$archive" "$url"

    extract "$archive"

    move_bin

elif [ $os = "linux" ]; then

    archive="archive.tar.xz"

    url="$url-linux64-gpl-shared.tar.xz"

    curl --retry 3 -L -o "$archive" "$url"

    tar -xf "$archive"

    rm "$archive"

    move_bin
else
    extract_mac "$url_mac/ffmpeg-$version_mac.zip"

    extract_mac "$url_mac/ffprobe-$version_mac.zip"
fi

#--------------------------------------------------------------------------------------------------
# Permissions
#--------------------------------------------------------------------------------------------------

if [ -f "ffmpeg" ]; then

    chmod +x "ffmpeg"
fi

if [ -f "ffprobe" ]; then

    chmod +x "ffprobe"
fi
