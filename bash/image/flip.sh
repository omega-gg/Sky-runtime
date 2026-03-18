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

flip="horizontal"

#--------------------------------------------------------------------------------------------------
# Functions
#--------------------------------------------------------------------------------------------------

getSky()
{
    if [ -n "$SKY_PATH_BIN" ]; then

        case `uname` in
            MINGW*|MSYS*|CYGWIN*)
                cygpath -u "$SKY_PATH_BIN/sky";;
            *)
                echo "$SKY_PATH_BIN/sky";;
        esac

        return
    fi

    case `uname` in
        MINGW*|MSYS*|CYGWIN*)
            cygpath -u "$LOCALAPPDATA/Sky-runtime/bin/sky";;
        Darwin*)
            echo "$HOME/Library/Application Support/Sky-runtime/bin/sky";;
        Linux*)
            echo "${XDG_DATA_HOME:-$HOME/.local/share}/Sky-runtime/bin/sky";;
        *)
            echo "$HOME/.local/share/Sky-runtime/bin/sky";;
    esac
}

#--------------------------------------------------------------------------------------------------
# Syntax
#--------------------------------------------------------------------------------------------------

if [ $# -lt 2 ] || [ $# -ge 3 -a "$3" != "horizontal" -a "$3" != "vertical" ]; then

    echo "Usage: flip <input> <output> [flip = $flip] [options...]"
    echo ""
    echo "examples:"
    echo "    flip input.png output.jpg horizontal -q:v 2"
    echo "    flip input.png output.webp vertical -c:v libwebp -lossless 1"

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# Configuration
#--------------------------------------------------------------------------------------------------

sky="$(getSky)"

ffmpeg="${SKY_PATH_FFMPEG:-$sky/ffmpeg}"

input="$1"

output="$2"

if [ $# = 2 ]; then

    shift 2
else
    flip="$3"

    shift 3
fi

if [ $flip = "horizontal" ]; then

    flip="hflip"
else
    flip="vflip"
fi

#--------------------------------------------------------------------------------------------------
# Run
#--------------------------------------------------------------------------------------------------

"$ffmpeg/ffmpeg" -y -i "$input" -vf "$flip" "$@" "$output"
