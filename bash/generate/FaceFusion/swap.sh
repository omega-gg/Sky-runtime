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

FaceFusion="${SKY_PATH_FACE_FUSION:-"$PWD/../../../user/bin/facefusion"}"

#--------------------------------------------------------------------------------------------------
# pinokio

pinokio="false"

# "/c/pinokio/api"
pinokio_path="$SKY_PATH_PINOKIO"

#--------------------------------------------------------------------------------------------------
# Syntax
#--------------------------------------------------------------------------------------------------

if [ $# != 3 ]; then

    echo "Usage: swap <input> <reference> <output>"

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# Run
#--------------------------------------------------------------------------------------------------

if [ $pinokio = "true" ]; then

    echo "swap: Using pinokio"

    path="$pinokio_path/facefusion-pinokio.git"

    FaceFusion="$path/facefusion"

    export PATH="$path/.env:$path/.env/Library/bin:$PATH"
fi

cd "$FaceFusion"

python facefusion.py headless-run \
    --target-path "$1" \
    --source-paths "$2" \
    --output-path "$3" \
    --face-swapper-model hyperswap_1a_256 \
    --face-swapper-pixel-boost 1024x1024 \
    --output-image-quality 100
