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

width="3840"
height="2160"

yuv="yuv420p"

#--------------------------------------------------------------------------------------------------
# Functions
#--------------------------------------------------------------------------------------------------

append()
{
    echo "file '$(getPath "$1")'" >> videos.txt
}

getOs()
{
    case `uname` in
    MINGW*|MSYS*|CYGWIN*) os="windows";;
    Darwin*)              os="macOS";;
    Linux*)               os="linux";;
    *)                    os="other";;
    esac

    type=`uname -m`

    if [ $type = "x86_64" ]; then

        if [ $os = "windows" ]; then

            echo win64
        else
            echo $os
        fi

    elif [ $os = "windows" ]; then

        echo win32
    else
        echo $os
    fi
}

getPath()
{
    if [ $os = "windows" ]; then

        cygpath -w "$1"
    else
        echo "$1"
    fi
}

getFps()
{
    "$ffmpeg/ffprobe" -v 0 -select_streams v:0 -show_entries stream=r_frame_rate -of csv=p=0 "$1" \
    | awk -F/ '{ printf "%.3f", $1 / $2 }'
}

#--------------------------------------------------------------------------------------------------
# Syntax
#--------------------------------------------------------------------------------------------------

if [ $# -lt 3 -o $# -gt 4 ]; then

    echo "Usage: concat-zoom <image> <video> <output>"
    echo "                   [codec | lossless]"
    echo ""
    echo "This command output is usefull to generate a wide background and turn 16:9 into 21:9 \
with a generative tool like Luma."

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# Configuration
#--------------------------------------------------------------------------------------------------

host=$(getOs)

if [ $host = "win32" -o $host = "win64" ]; then

    os="windows"
else
    os="default"
fi

fps=$(getFps "$2")

if [ $# -lt 4 ]; then

    codec="-codec:v libx264 -crf 15 -preset slow"

elif [ "$4" = "lossless" ]; then

    codec="-codec:v libx264 -preset veryslow -qp 0 -pix_fmt $yuv"
else
    codec="$4"
fi

#--------------------------------------------------------------------------------------------------
# Run
#--------------------------------------------------------------------------------------------------

ratio=$(awk "BEGIN { printf \"%.6f\", $width / $height }")

frames=$(awk "BEGIN { print int($fps * 1) }")

zoom=$(awk "BEGIN { print (1.333 - 1) / $frames }")

echo "concat-zoom: Generating input image frames..."

mkdir -p frames

for i in $(seq 0 $((frames - 1))); do

    scale=$(awk "BEGIN { print 1 + ($i * $zoom) }")

    "ffmpeg/$ffmpeg" -y -loop 1 -t 1 -i "$1" -vf "\
        scale=if(gt(a\,${ratio})\,${width}\,-1):if(gt(a\,${ratio})\,-1\,${height}):flags=lanczos, \
        pad=${width}:${height}:(ow-iw)/2:(oh-ih)/2, \
        scale=iw*${scale}:ih*${scale}:flags=lanczos, \
        crop=${width}:${height}:(in_w-${width})/2:(in_h-${height})/2" \
        -frames:v 1 "frames/frame$(printf "%04d" "$i").png"
done

"$ffmpeg" -y -framerate "$fps" -i frames/frame%04d.png \
          -c:v libx264 -preset veryslow -qp 0 -pix_fmt $yuv "temp.mp4"

rm -rf frames

append "temp.mp4"
append "$2"

"$ffmpeg" -y -f concat -safe 0 -i videos.txt $codec -pix_fmt $yuv -c:a copy "$3"

#--------------------------------------------------------------------------------------------------
# Clean
#--------------------------------------------------------------------------------------------------

rm temp.mp4

rm videos.txt
