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

ffmpeg="${SKY_PATH_FFMPEG:-"$PWD/../../user/bin/ffmpeg"}"

filter="bilinear"

#--------------------------------------------------------------------------------------------------
# Syntax
#--------------------------------------------------------------------------------------------------

if [ $# != 4 -a $# != 5 ]; then

    echo "Usage: resize <input> <output> <width> <height> [filter = bilinear]"
    echo ""
    echo "filter: fast_bilinear"
    echo "        bilinear"
    echo "        bicubic"
    echo "        experimental"
    echo "        neighbor"
    echo "        area"
    echo "        bicublin"
    echo "        gauss"
    echo "        sinc"
    echo "        lanczos"
    echo "        spline"
    echo "        print_info"
    echo "        accurate_rnd"
    echo "        full_chroma_int"
    echo "        full_chroma_inp"
    echo "        bitexact"
    echo "        unstable"

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# Configuration
#--------------------------------------------------------------------------------------------------

if [ $# -gt 4 ]; then

    filter="$5"
fi

#--------------------------------------------------------------------------------------------------
# Run
#--------------------------------------------------------------------------------------------------

"$ffmpeg" -y -i "$1" -vf "scale=$3:$4:flags=$filter" "$2"
