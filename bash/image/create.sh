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

magick="${SKY_PATH_IMAGE_MAGICK:-$SKY_PATH_BIN/imageMagick}"

#--------------------------------------------------------------------------------------------------
# Syntax
#--------------------------------------------------------------------------------------------------

if [ $# -lt 2 ]; then

    echo "Usage: create <output> <layer1> [layer2 ...]"
    echo ""
    echo "examples:"
    echo "    create output.png input.svg"
    echo "    create output.psd layer1.png layer2.png"

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# Run
#--------------------------------------------------------------------------------------------------

output="$1"

shift

if echo "$@" | grep -Eiq '\.(svg|pdf)(\s|$)'; then

    set -- -density 384 "$@"
fi

if echo "$output" | grep -Eiq '\.(png|psd|tif|tiff|webp)$'; then

    color="none"
else
    color="white"
fi

if echo "$output" | grep -qi '\.psd$'; then

    if [ $# -gt 1 ]; then

        "$magick/magick" -background "$color" "$@" \
            \( -clone 0--1 -background "$color" -layers merge \) \
            -insert 0 \
            -define psd:write-layers=true \
            -alpha set "$output"
    else
        "$magick/magick" -background "$color" "$@" -alpha set "$output"
    fi
else
    "$magick/magick" -background "$color" "$@" -alpha set -layers merge "$output"
fi
