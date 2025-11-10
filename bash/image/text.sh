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

font_folder="${SKY_PATH_FONT:-"$SKY_PATH_BIN/font"}"

size="64"

position="bottom"

color="#00dc00"

color_background="#00000000"

ratio="1.8"

font="arial.ttf"

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

if [ $# -lt 3 -o $# -gt 9 ]; then

    echo "Usage: text <input> <output> <text> [size = $size] [position = $position]"
    echo "            [color = $color] [color_background = $color_background] [font = $font]"
    echo "            [ratio = $ratio]"
    echo ""
    echo "position: left, top, bottom, right"
    echo ""
    echo "examples:"
    echo "    text input.png output.png \"text\""
    echo "    text input.png output.png \"text\" 128 left green white verdana.ttf"

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# Configuration
#--------------------------------------------------------------------------------------------------

if [ $# -ge 4 ]; then size="$4"; fi

if [ $# -ge 5 ]; then position=$(printf '%s' "$5" | tr '[:upper:]' '[:lower:]'); fi

if [ $# -ge 6 ]; then color="$6"; fi

if [ $# -ge 7 ]; then color_background="$7"; fi

if [ $# -ge 8 ]; then font="$8"; fi

if [ $# -ge 9 ]; then ratio="$9"; fi

#--------------------------------------------------------------------------------------------------
# Run
#--------------------------------------------------------------------------------------------------

width=$(getWidth "$1")

height=$(getHeight "$1")

extra_height=$(awk "BEGIN {print int($size * $ratio)}")

case "$(uname -s 2> /dev/null)" in

    MINGW*|MSYS*|CYGWIN*)
        font_folder="$(printf "%s" "$font_folder" | sed 's#\\#/#g; s#^\([A-Za-z]\):#\1\\:#')"
        ;;
esac

drawtext="drawtext=text='$3':fontcolor=$color:fontsize=$size:fontfile='$font_folder/$font':\
x=(w-text_w)/2:y=(h-text_h)/2"

case "$position" in

    left)
        total_width=$((width + extra_height))

        total_height="$height"

        fc="[0:v]format=rgba,pad=w=${total_width}:h=${total_height}:x=${extra_height}:y=0:\
color=${color_background}[base];color=c=${color_background}:s=${height}x${extra_height}[tbg];\
[tbg]${drawtext},rotate=PI/2:ow=${extra_height}:oh=${height}:fillcolor=${color_background}[txt];\
[base][txt]overlay=x=0:y=0[out]"
        ;;

    top)
        total_width="$width"

        total_height=$((height + extra_height))

        fc="[0:v]format=rgba,pad=w=${total_width}:h=${total_height}:x=0:y=${extra_height}:\
color=${color_background}[base];color=c=${color_background}:s=${width}x${extra_height}[tbg];\
[tbg]${drawtext}[txt];[base][txt]overlay=x=0:y=0[out]"
        ;;

    right)
        total_width=$((width + extra_height))

        total_height="$height"

        fc="[0:v]format=rgba,pad=w=${total_width}:h=${total_height}:x=0:y=0:\
color=${color_background}[base];color=c=${color_background}:s=${height}x${extra_height}[tbg];\
[tbg]${drawtext},rotate=-PI/2:ow=${extra_height}:oh=${height}:fillcolor=${color_background}[txt];\
[base][txt]overlay=x=${width}:y=0[out]"
        ;;

    *)
        total_width="$width"

        total_height=$((height + extra_height))

        fc="[0:v]format=rgba,pad=w=${total_width}:h=${total_height}:x=0:y=0:\
color=${color_background}[base];color=c=${color_background}:s=${width}x${extra_height}[tbg];\
[tbg]${drawtext}[txt];[base][txt]overlay=x=0:y=${height}[out]"
        ;;
esac

"$ffmpeg" -y -i "$1" -filter_complex "$fc" -map "[out]" -frames:v 1 "$2"
