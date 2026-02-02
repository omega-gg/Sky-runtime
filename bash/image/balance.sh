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

ffmpeg="${SKY_PATH_FFMPEG:-"$SKY_PATH_BIN/ffmpeg"}"

#--------------------------------------------------------------------------------------------------
# Syntax
#--------------------------------------------------------------------------------------------------

if [ $# != 5 ]; then

    echo "Usage: color <input> <output> <red> <green> <blue>"
    echo ""
    echo "red, green, blue: -1.0 to 1.0 (default = 0.0)"
    echo ""
    echo "example:"
    echo "    color input.png output.jpg 0.1 0 -0.1"

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# Run
#--------------------------------------------------------------------------------------------------

input="$1"

output="$2"

red="$3"

green="$4"

blue="$5"

filter="colorbalance=\
rs=${red}:gs=${green}:bs=${blue}:\
rm=${red}:gm=${green}:bm=${blue}:\
rh=${red}:gh=${green}:bh=${blue}:\
pl=1"

"$ffmpeg/ffmpeg" -y -i "$input" -vf "$filter" "$output"
