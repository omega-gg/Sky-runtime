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

yuv="yuv420p"

#--------------------------------------------------------------------------------------------------
# Syntax
#--------------------------------------------------------------------------------------------------

if [ $# -lt 4 -o $# -gt 6 ] || [ $# = 5 -a "$5" != "precise" ]; then

    echo "Usage: cut <video> <timeA> <timeB> <output> [precise]"
    echo "           [codec | lossless]"

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# Configuration
#--------------------------------------------------------------------------------------------------

if [ $# -lt 6 ]; then

    codec="-codec:v libx264 -crf 15 -preset slow"

elif [ "$6" = "lossless" ]; then

    codec="-codec:v libx264 -preset veryslow -qp 0 -pix_fmt $yuv"
else
    codec="$6"
fi

#--------------------------------------------------------------------------------------------------
# Run
#--------------------------------------------------------------------------------------------------

# NOTE: The order of -i parameter matters and the frame cut is not perfect.
#       https://stackoverflow.com/questions/18444194/cutting-multimedia-files-based-on-start-and-end-time-using-ffmpeg

if [ "$5" = "precise" ]; then

    "$ffmpeg/ffmpeg" -y -i "$1" -ss "$2" -to "$3" $codec -c:a copy "$4"
else
    "$ffmpeg/ffmpeg" -y -ss "$2" -to "$3" -i "$1" -c copy "$4"
fi
