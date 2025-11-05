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

name="color_transfer"

repository="https://github.com/jrosebr1/color_transfer.git"

commit="6724ccf"

#--------------------------------------------------------------------------------------------------
# Syntax
#--------------------------------------------------------------------------------------------------

if [ $# != 1 ] || [ "$1" != "default" -a "$1" != "headless" ]; then

    echo "Usage: build <default | headless>"
    echo ""
    echo "example:"
    echo "    build headless"

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# Clean
#--------------------------------------------------------------------------------------------------

cd "$bin"

rm -rf "$name"

#--------------------------------------------------------------------------------------------------
# Clone
#--------------------------------------------------------------------------------------------------

git clone "$repository" "$name"

cd "$name"

git checkout "$commit"

#--------------------------------------------------------------------------------------------------
# Environment
#--------------------------------------------------------------------------------------------------

python -m venv .venv

if [ -f ".venv/Scripts/activate" ]; then

    # Windows / Git Bash
    activate=".venv/Scripts/activate"
else
    activate=".venv/bin/activate"
fi

. "$activate"

#--------------------------------------------------------------------------------------------------
# Install
#--------------------------------------------------------------------------------------------------

python -m pip install --upgrade pip

if [ "$1" = "headless" ]; then

    python -m pip install numpy opencv-python-headless
else
    python -m pip install numpy opencv-python
fi

python -m pip install -e .
