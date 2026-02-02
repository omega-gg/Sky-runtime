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

root="$(dirname "$0")"

ffmpeg="${SKY_PATH_FFMPEG:-"$SKY_PATH_BIN/ffmpeg"}"

ffprobe="${SKY_PATH_FFPROBE:-"$SKY_PATH_BIN/ffprobe"}"

magick="${SKY_PATH_IMAGE_MAGICK:-"$SKY_PATH_BIN/imageMagick"}"

size="64"

position="bottom"

color_background="#00000000"

ratio="1.8"

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

if [ $# -lt 3 -o $# -gt 7 ]; then

    echo "Usage: icon <input> <output> <icon> [size = $size] [position = $position]"
    echo "            [color_background = $color_background] [ratio = $ratio]"
    echo ""
    echo "position: left, top, bottom, right"
    echo ""
    echo "examples:"
    echo "    icon input.png output.png icon.png"
    echo "    icon input.png output.png icon.svg 128 left white 2.4"

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# Configuration
#--------------------------------------------------------------------------------------------------

if [ $# -ge 4 ]; then size="$4"; fi

if [ $# -ge 5 ]; then position=$(printf '%s' "$5" | tr '[:upper:]' '[:lower:]'); fi

if [ $# -ge 6 ]; then color_background="$6"; fi

if [ $# -ge 7 ]; then ratio="$7"; fi

#--------------------------------------------------------------------------------------------------
# Run
#--------------------------------------------------------------------------------------------------

width=$(getWidth "$1")

height=$(getHeight "$1")

extra_height=$(awk "BEGIN {print int($size * $ratio)}")

icon="$3"

if echo "$icon" | grep -qi '\.svg$'; then

    temp="$root/temp.png"

    "$root"/create-size.sh "$temp" "$size" "$icon"

    icon="$temp"
fi

case "$position" in

    left)
        total_width=$((width + extra_height))

        total_height="$height"

        fc="[0:v]format=rgba,pad=w=${total_width}:h=${total_height}:x=${extra_height}:y=0:\
color=${color_background}[base];[1:v]scale=w=${size}:h=${size}:\
force_original_aspect_ratio=decrease[ico];[ico]pad=w=${extra_height}:h=${height}:\
x=(ow-iw)/2:y=(oh-ih)/2:\
color=${color_background}[iconstrip];[base][iconstrip]overlay=x=0:y=0[out]"
        ;;

    top)
        total_width="$width"

        total_height=$((height + extra_height))

        fc="[0:v]format=rgba,pad=w=${total_width}:h=${total_height}:x=0:y=${extra_height}:\
color=${color_background}[base];[1:v]scale=w=${size}:h=${size}:\
force_original_aspect_ratio=decrease[ico];[ico]pad=w=${width}:h=${extra_height}:\
x=(ow-iw)/2:y=(oh-ih)/2:\
color=${color_background}[iconstrip];[base][iconstrip]overlay=x=0:y=0[out]"
        ;;

    right)
        total_width=$((width + extra_height))

        total_height="$height"

        fc="[0:v]format=rgba,pad=w=${total_width}:h=${total_height}:x=0:y=0:\
color=${color_background}[base];[1:v]scale=w=${size}:h=${size}:\
force_original_aspect_ratio=decrease[ico];[ico]pad=w=${extra_height}:h=${height}:\
x=(ow-iw)/2:y=(oh-ih)/2:\
color=${color_background}[iconstrip];[base][iconstrip]overlay=x=${width}:y=0[out]"
        ;;

    *)
        total_width="$width"

        total_height=$((height + extra_height))

        fc="[0:v]format=rgba,pad=w=${total_width}:h=${total_height}:x=0:y=0:\
color=${color_background}[base];[1:v]scale=w=${size}:h=${size}:\
force_original_aspect_ratio=decrease[ico];[ico]pad=w=${width}:h=${extra_height}:\
x=(ow-iw)/2:y=(oh-ih)/2:\
color=${color_background}[iconstrip];[base][iconstrip]overlay=x=0:y=${height}[out]"
        ;;
esac

"$ffmpeg" -y -i "$1" -i "$icon" -filter_complex "$fc" -map "[out]" -frames:v 1 "$2"

#--------------------------------------------------------------------------------------------------
# Clean
#--------------------------------------------------------------------------------------------------

if [ -n "$temp" ]; then rm -f "$temp"; fi
