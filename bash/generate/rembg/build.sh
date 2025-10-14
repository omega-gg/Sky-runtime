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

# NOTE: CPU does not seem much slower than the GPU for a single image.

#--------------------------------------------------------------------------------------------------
# Settings
#--------------------------------------------------------------------------------------------------

bin="$SKY_PATH_BIN"

name="rembg"

repository="https://github.com/danielgatis/rembg.git"

version="v2.0.67"

#--------------------------------------------------------------------------------------------------
# Syntax
#--------------------------------------------------------------------------------------------------

if [ $# != 1 -a $# != 2 ] || [ $# = 2 -a "$2" != "cuda" ]; then

    echo "Usage: build <options> [cuda]"
    echo ""
    echo "options: cpu, gpu, cli"
    echo ""
    echo "example:"
    echo "    build \"gpu,cli\" cuda"

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

git clone --depth=1 --branch "$version" "$repository"

cd "$name"

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

python -m pip install ".[$1]"

if [ "$2" = "cuda" ]; then

    python -m pip install nvidia-cudnn-cu12

    echo 'export PATH="$VIRTUAL_ENV/Lib/site-packages/nvidia/cudnn/bin:\
$VIRTUAL_ENV/Lib/site-packages/nvidia/cublas/bin:$PATH"' >> "$activate"
fi

# FIXME: https://github.com/microsoft/onnxruntime/issues/26261

case "$1" in
    *gpu*) gpu=true  ;;
    *)     gpu=false ;;
esac

if [ "$gpu" = true ]; then

    python -m pip uninstall -y onnxruntime-gpu

    python -m pip install "onnxruntime-gpu==1.22.0"
else
    python -m pip uninstall -y onnxruntime

    python -m pip install "onnxruntime==1.22.0"
fi
