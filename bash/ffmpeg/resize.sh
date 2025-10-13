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

ffprobe="${SKY_PATH_FFPROBE:-"$PWD/../../user/bin/ffprobe"}"

yuv="yuv420p"

#--------------------------------------------------------------------------------------------------
# Functions
#--------------------------------------------------------------------------------------------------

getDuration()
{
    "$ffprobe" -i "$1" -show_entries format=duration -v quiet -of csv="p=0"
}

#--------------------------------------------------------------------------------------------------
# Syntax
#--------------------------------------------------------------------------------------------------

if [ $# -lt 3 -o $# -gt 6 ]; then

    echo "Usage: resize <video> <reference video> <output> [skip=0] [chop=0]"
    echo "              [codec | lossless]"

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# Run
#--------------------------------------------------------------------------------------------------

durationA=$(getDuration "$1")
durationB=$(getDuration "$2")

if [ $# -gt 3 ]; then

    duration=$(awk "BEGIN { print $durationB - $durationA + $4 }")

    if [ "$4" = "0" ]; then

        skip=""
    else
        skip="-ss $4"
    fi
else
    duration=$(awk "BEGIN { print $durationB - $durationA }")

    skip=""
fi

if [ $# -lt 6 ]; then

    codec="-codec:v libx264 -crf 15 -preset slow"

elif [ "$6" = "lossless" ]; then

    codec="-codec:v libx264 -preset veryslow -qp 0 -pix_fmt $yuv"
else
    codec="$6"
fi

check=$(awk "BEGIN { print ($duration <= 0) }")

if [ "$check" = 1 ]; then

    if [ $# = 5 ]; then

        duration=$(awk "BEGIN { print $durationB - $5 }")
    else
        duration="$durationB"
    fi

    "$ffmpeg" -y -i "$1" $skip -t "$duration" $codec -c:a copy "$3"
else
    if [ $# = 5 ]; then

        duration=$(awk "BEGIN { print $duration - $5 }")
    fi

    "$ffmpeg" -y -i "$1" $skip -vf "tpad=stop_mode=clone:stop_duration=$duration" $codec -c:a copy "$3"
fi
