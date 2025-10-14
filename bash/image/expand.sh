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

ffprobe="${SKY_PATH_FFPROBE:-"$SKY_PATH_BIN/ffprobe"}"

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

if [ $# -lt 3 -o $# -gt 5 ]; then

    echo "Usage: expand <input> <output> <width | ratio> [height] [color]"
    echo ""
    echo "examples: expand input.png output.png 128 128 white"
    echo "          expand input.png output.png 16:9"
    echo "          expand input.png output.png 2.39:1"

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# Configuration
#--------------------------------------------------------------------------------------------------

input_width=$(getWidth "$1")

input_height=$(getHeight "$1")

if echo "$3" | grep -q ":"; then

    ratio=$(echo "$3" | tr ',' '.')

    ratio_width="${ratio%%:*}"

    ratio_height="${ratio#*:}"

    # NOTE: Convert float ratio (e.g. 2.39:1 -> 239:100).
    if echo "$ratio_width" | grep -q '\.'; then

        ratio_width="${ratio_width/./}"

        ratio_height="${ratio_height}00"
    fi
else
    ratio_width=""
fi

if [ -n "$ratio_width" ]; then

    target_height=$(( input_width * ratio_height / ratio_width ))

    if [ $target_height -ge $input_height ]; then

        extra_width="0"

        extra_height=$(( (target_height - input_height) / 2 ))
    else
        target_width=$(( input_height * ratio_width / ratio_height ))

        extra_width=$(( (target_width - input_width) / 2 ))

        extra_height="0"
    fi
else
    extra_width="$3"

    if [ $# -gt 3 ]; then

        extra_height="$4"
    else
        extra_height="0"
    fi
fi

#--------------------------------------------------------------------------------------------------
# Run
#--------------------------------------------------------------------------------------------------

output_width=$(( input_width + 2 * extra_width ))

output_height=$(( input_height + 2 * extra_height ))

if [ $# -gt 4 ]; then

    bg="$5"
else
    bg="black"
fi

color="color=size=${output_width}x${output_height}:\
c=${bg}[bg];[bg][0:v]overlay=${extra_width}:${extra_height}"

"$ffmpeg" -y -i "$1" -filter_complex "$color" -frames:v 1 "$2"
