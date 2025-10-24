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

getSize()
{
    if echo "$2" | grep -Eq '^[0-9]*\.[0-9]+$'; then

        awk -v s="$1" -v f="$2" 'BEGIN {
            if (f < 0) f = 0;
            if (f > 1) f = 1;
            printf "%d", s * f;
        }'
    else
        printf "%d" "$2"
    fi
}

#--------------------------------------------------------------------------------------------------
# Syntax
#--------------------------------------------------------------------------------------------------

if [ $# -lt 3 -o $# -gt 7 ]; then

    echo "Usage: expand <input> <output> <left | ratio> [top] [right = left] [bottom = top]"
    echo "              [color = transparent]"
    echo ""
    echo "examples: expand input.png output.png 128 128 white"
    echo "          expand input.png output.png 32 64 48 56"
    echo "          expand input.png output.png 0.3 0.2"
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

    ratio="$3"

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

        extra_left="0"

        extra_right="0"

        extra_top=$(( (target_height - input_height) / 2 ))

        extra_bottom="$extra_top"

        output_width="$input_width"

        output_height=$(( input_height + extra_top + extra_bottom ))
    else
        target_width=$(( input_height * ratio_width / ratio_height ))

        extra_left=$(( (target_width - input_width) / 2 ))

        extra_right="$extra_left"

        extra_top="0"

        extra_bottom="0"

        output_width=$(( input_width + extra_left + extra_right ))

        output_height="$input_height"
    fi

    if [ $# -ge 4 ]; then

        bg="$4"
    else
        bg="#00000000"
    fi
else
    extra_left=$(getSize "$input_width" "$3")

    extra_top=$(getSize "$input_height" "${4:-0}")

    extra_right=$(getSize "$input_width" "${5:-$extra_left}")

    extra_bottom=$(getSize "$input_height" "${6:-$extra_top}")

    output_width=$(( input_width + extra_left + extra_right ))

    output_height=$(( input_height + extra_top + extra_bottom ))

    if [ $# -ge 7 ]; then

        bg="$7"
    else
        bg="#00000000"
    fi
fi

#--------------------------------------------------------------------------------------------------
# Run
#--------------------------------------------------------------------------------------------------

color="color=size=${output_width}x${output_height}:\
c=${bg}[bg];[bg][0:v]overlay=${extra_left}:${extra_top}"

"$ffmpeg" -y -i "$1" -filter_complex "$color" -frames:v 1 "$2"
