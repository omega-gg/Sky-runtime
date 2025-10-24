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

angle="90"

#--------------------------------------------------------------------------------------------------
# Syntax
#--------------------------------------------------------------------------------------------------

if [ $# -lt 2 ] \
   || \
   [ $# -ge 3 -a "$3" != "90" -a "$3" != "-90" -a "$3" != "180" -a "$3" != "270" ]; then

    echo "Usage: rotate <input> <output> [angle = $angle] [options...]"
    echo ""
    echo "examples:"
    echo "    rotate input.png output.jpg  180"
    echo "    rotate input.png output.webp -90 -c:v libwebp -lossless 1"

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# Configuration
#--------------------------------------------------------------------------------------------------

input="$1"

output="$2"

if [ $# = 2 ]; then

    shift 2
else
    angle="$3"

    shift 3
fi

#--------------------------------------------------------------------------------------------------
# Run
#--------------------------------------------------------------------------------------------------

case "$angle" in

    180)     angle="transpose=1,transpose=1" ;;
    270|-90) angle="transpose=2"             ;;
    *)       angle="transpose=1"             ;;
esac

"$ffmpeg" -y -i "$input" -vf "$angle" "$@" "$output"
