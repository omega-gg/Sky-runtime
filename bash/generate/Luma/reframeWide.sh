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

root="$PWD"

ffmpeg="${SKY_PATH_FFMPEG:-"$PWD/../../../user/bin/ffmpeg"}"

#--------------------------------------------------------------------------------------------------
# Syntax
#--------------------------------------------------------------------------------------------------

if [ $# -lt 3 -o $# -gt 4 ]; then

    echo "Usage: reframeWide <image> <video> <output>"
    echo "                   [codec | lossless]"
    echo ""
    echo "This command output is usefull to turn 16:9 into 21:9 with Luma reframe."

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# Run
#--------------------------------------------------------------------------------------------------

echo "----------"
echo "GENERATING"
echo "----------"

cd "$ffmpeg"

# NOTE: We don't use a generic name to avoid caching issues with Amazon S3 hosting.
filename=$(basename -- "$2")

# NOTE: Luma does not support lossless video input for now.
sh concatZoom.sh "$1" "$2" "$root/$filename"

cd -

echo "---------"
echo "REFRAMING"
echo "---------"

sh reframe.sh "$filename" temp.mp4 21:9

rm "$filename"

echo "--------"
echo "RESIZING"
echo "--------"

cd "$ffmpeg"

if [ $# -lt 4 ]; then

    sh resize.sh "$root/temp.mp4" "$2" "$3" 1
else
    sh resize.sh "$root/temp.mp4" "$2" "$3" 1 0 "$4"
fi

cd -

#--------------------------------------------------------------------------------------------------
# Clean
#--------------------------------------------------------------------------------------------------

rm temp.mp4
