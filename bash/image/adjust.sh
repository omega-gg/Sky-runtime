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

if [ $# != 3 -a $# != 4 ]; then

    echo "Usage: adjust <input> <output> <brightness> [contrast]"
    echo ""
    echo "brightness: default = 0.0"
    echo "contrast:   default = 1.0"
    echo ""
    echo "examples:"
    echo "    adjust input.png output.jpg 0.5 1.2"

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# Run
#--------------------------------------------------------------------------------------------------

input="$1"

output="$2"

brightness="$3"

if [ $# = 4 ]; then

    contrast="$4"
else
    contrast="1.0"
fi

filter="eq=brightness=${brightness}:contrast=${contrast}"

"$ffmpeg" -y -i "$input" -vf "$filter" "$output"
