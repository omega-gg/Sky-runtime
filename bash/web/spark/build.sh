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

name="spark"

repository="https://github.com/sparkjsdev/spark.git"

version="v0.1.10"

python="Programs/Python/Python312/Scripts"

#--------------------------------------------------------------------------------------------------
# Functions
#--------------------------------------------------------------------------------------------------

check()
{
    if ! command -v "$1" >/dev/null 2>&1; then

        echo "build: '$1' is required but not found in PATH."

        exit 1
    fi
}

#--------------------------------------------------------------------------------------------------
# Syntax
#--------------------------------------------------------------------------------------------------

if [ $# != 1 ] || [ "$1" != "default" ]; then

    echo "Usage: build <default>"

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# Environment
#--------------------------------------------------------------------------------------------------

check git
check python
check node
check npm
check rustc
check cargo

#--------------------------------------------------------------------------------------------------
# Clean
#--------------------------------------------------------------------------------------------------

cd "$bin"

rm -rf "$name"

#--------------------------------------------------------------------------------------------------
# Clone
#--------------------------------------------------------------------------------------------------

git clone --depth=1 --branch "$version" "$repository"

cd "$name"

#--------------------------------------------------------------------------------------------------
# Environment
#--------------------------------------------------------------------------------------------------

if [ -n "$LOCALAPPDATA" ]; then

    path="$(cygpath "$LOCALAPPDATA")/$python"

    if [ -d "$path" ]; then

        export PATH="$PATH:$path"
    fi
fi

#--------------------------------------------------------------------------------------------------
# Install
#--------------------------------------------------------------------------------------------------

python -m pip install --upgrade pip

python -m pip install mkdocs mkdocs-material

if [ -f "package-lock.json" ]; then

    npm ci
else
    npm install
fi

npm run build

npm run assets:download

npm run site:build
