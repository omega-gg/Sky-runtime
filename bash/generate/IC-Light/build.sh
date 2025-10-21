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

name="IC-Light"

repository="https://github.com/lllyasviel/IC-Light.git"

commit="bcf3f29"

#--------------------------------------------------------------------------------------------------
# Syntax
#--------------------------------------------------------------------------------------------------

if [ $# != 1 ] || [ $1 != "default" ]; then

    echo "Usage: build <default>"

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
  . ".venv/Scripts/activate"
else
  . ".venv/bin/activate"
fi

#--------------------------------------------------------------------------------------------------
# Install
#--------------------------------------------------------------------------------------------------

python -m pip install --upgrade pip

python -m pip install torch torchvision --index-url https://download.pytorch.org/whl/cu121

# NOTE: huggingface_hub is required.
python -m pip install "huggingface_hub==0.25.0"

python -m pip install -r requirements.txt

# NOTE: peft is causing an issue.
python -m pip uninstall -y gradio peft

# NOTE: The old gradio causes an error on the UI.
python -m pip install gradio==3.50.2
