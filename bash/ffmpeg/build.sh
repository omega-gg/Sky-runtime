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

name="ffmpeg"

url="https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.5.0/realesrgan-ncnn-vulkan-20220424"

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
# Download
#--------------------------------------------------------------------------------------------------

mkdir -p "$name"

cd "$name"

case `uname` in
    MINGW*)  os="windows";;
    Darwin*) os="macos";;
    Linux*)  os="ubuntu";;
    *)       os="other";;
esac

if [ $os = "other" ]; then

    echo "build: Unsupported OS."

    exit 1
fi

url="$url-$os.zip"

archive="archive.zip"

curl -L -o "$archive" "$url"

#--------------------------------------------------------------------------------------------------
# Extract
#--------------------------------------------------------------------------------------------------

python - <<EOF
import os, zipfile, sys
dst = os.path.abspath(".")
zip_path = os.path.abspath("$archive")
with zipfile.ZipFile(zip_path, "r") as z:
    z.extractall(dst)
print("Extracted to:", dst)
EOF

rm "$archive"

#--------------------------------------------------------------------------------------------------
# Permissions
#--------------------------------------------------------------------------------------------------

if [ -f "realesrgan-ncnn-vulkan" ]; then

    chmod +x "realesrgan-ncnn-vulkan"
fi
