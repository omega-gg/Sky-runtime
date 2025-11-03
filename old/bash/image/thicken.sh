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

radius="8"

color="black"

#--------------------------------------------------------------------------------------------------
# Syntax
#--------------------------------------------------------------------------------------------------

if [ $# -lt 2 -o $# -gt 4 ]; then

    echo "Usage: thicken <input> <output> [radius = $radius] [color = $color]"
    echo ""
    echo "examples: thicken input.png output.png 16 white"

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# Configuration
#--------------------------------------------------------------------------------------------------

if [ $# -ge 3 ]; then radius="$3"; fi

if [ $# -ge 4 ]; then color="$4"; fi

#--------------------------------------------------------------------------------------------------
# Run
#--------------------------------------------------------------------------------------------------

# NOTE: Build a chain of 'dilation' filters repeated $radius times (since 'radius=' is not
#       supported)

passes=""

i=0

while [ "$i" -lt "$radius" ]; do

    passes="${passes}dilation,"

    i=$((i + 1))
done

# NOTE: strip trailing comma (handle radius=0 too).
passes="${passes%,}"

"$ffmpeg" -y -i "$1" -filter_complex "\
[0:v]format=rgba,split[base][alpha_src]; \
[alpha_src]alphaextract,format=gray${passes:+,${passes}}[a_thick]; \
color=c=${color}:s=16x16,format=rgba[colsrc]; \
[colsrc][base]scale2ref[col][base_sized]; \
[col][a_thick]alphamerge[col_sil]; \
[col_sil][base_sized]overlay=format=auto[final] \
" -map "[final]" -frames:v 1 "$2"
