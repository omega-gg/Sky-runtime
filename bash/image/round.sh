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

radius="32"

feather="1.0"

#--------------------------------------------------------------------------------------------------
# Syntax
#--------------------------------------------------------------------------------------------------

if [ $# -lt 2 -o $# -gt 4 ]; then

    echo "Usage: round <input> <output> [radius = $radius] [feather = $feather]"
    echo ""
    echo "examples: round output.png 64 1.5"

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# Configuration
#--------------------------------------------------------------------------------------------------

if [ $# -ge 3 ]; then radius="$3"; fi

if [ $# -ge 4 ]; then feather="$4"; fi

#--------------------------------------------------------------------------------------------------
# Run
#--------------------------------------------------------------------------------------------------

"$ffmpeg" -y -i "$1" -vf "\
format=rgba,geq=\
r='r(X\,Y)':g='g(X\,Y)':b='b(X\,Y)':a='\
clip( \
(- ( hypot( \
max(abs(X-(W/2))-(W/2-$radius)\, 0) \, \
max(abs(Y-(H/2))-(H/2-$radius)\, 0) ) \
+ min( max(abs(X-(W/2))-(W/2-$radius) \, abs(Y-(H/2))-(H/2-$radius)) \, 0 ) \
- $radius ) ) / $feather * 255 \
\, 0 \, 255)'" \
-frames:v 1 "$2"
