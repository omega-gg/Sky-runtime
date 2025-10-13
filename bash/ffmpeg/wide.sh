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

width="5160"
height="2160"

base="3840"

yuv="yuv420p"

#--------------------------------------------------------------------------------------------------
# Functions
#--------------------------------------------------------------------------------------------------

getWidth()
{
    "$ffprobe" -v error -select_streams v:0 -show_entries stream=width -of csv=p=0 "$1"
}

getHeight()
{
    "$ffprobe" -v error -select_streams v:0 -show_entries stream=height -of csv=p=0 "$1"
}

#--------------------------------------------------------------------------------------------------
# Syntax
#--------------------------------------------------------------------------------------------------

if [ $# -lt 2 -o $# -gt 3 ]; then

    echo "Usage: wide <video> <output> [codec | lossless]"

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# Run
#--------------------------------------------------------------------------------------------------

input_width=$(getWidth "$1")

input_height=$(getHeight "$1")

size=$(awk "BEGIN { print ($input_width - $base) / 2 }")

right=$(awk "BEGIN { print $input_width - $size }")

scale=$(awk "BEGIN { print $size + ($width - $input_width) / 2 }")

if [ $# -lt 3 ]; then

    codec="-codec:v libx264 -crf 15 -preset slow"

elif [ "$3" = "lossless" ]; then

    codec="-codec:v libx264 -preset veryslow -qp 0 -pix_fmt $yuv"
else
    codec="$3"
fi

"$ffmpeg" -y -i "$1" -filter_complex "\
    [0:v]crop=$size:$height:0:0[left]; \
    [0:v]crop=$size:$height:$right:0[right]; \
    [0:v]crop=$base:$height:$size:0[center]; \
    [left]scale=$scale:$height[left_stretched]; \
    [right]scale=$scale:$height[right_stretched]; \
    [left_stretched][center][right_stretched]hstack=3[output]" \
    -map "[output]" $codec -c:a copy "$2"
