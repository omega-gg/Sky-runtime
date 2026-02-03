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

ffmpeg="${SKY_PATH_FFMPEG:-$SKY_PATH_BIN/ffmpeg}"

#--------------------------------------------------------------------------------------------------
# Syntax
#--------------------------------------------------------------------------------------------------

if [ $# != 3 -a $# != 4 ] || [ $# = 4 -a "$4" != "fast" ]; then

    echo "Usage: frame <video> <time> <output image> [fast]"
    echo ""
    echo "Timestamp formats:"
    echo "    ss[.ms]         26.5"
    echo "    m:ss[.ms]       0:26.250"
    echo "    h:mm:ss[.ms]    00:00:26.123"
    echo ""
    echo "example:"
    echo "    frame input.mp4 2:10 frame.png"

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# Run
#--------------------------------------------------------------------------------------------------

# NOTE: Placing -ss after -i is slower but more accurate.

if [ "$4" = "fast" ]; then

    "$ffmpeg/ffmpeg" -y -ss "$2" -i "$1" -frames:v 1 -an "$3"
else
    "$ffmpeg/ffmpeg" -y -i "$1" -ss "$2" -frames:v 1 -an "$3"
fi
