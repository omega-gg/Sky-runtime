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

if [ $# != 3 ]; then

    echo "Usage: concat <videoA> <video2> <output>"

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# Configuration
#--------------------------------------------------------------------------------------------------

sky="$(getSky)"

ffmpeg="${SKY_PATH_FFMPEG:-$sky/ffmpeg}"

echo "file '$1'" >  videos.txt
echo "file '$2'" >> videos.txt

#--------------------------------------------------------------------------------------------------
# Run
#--------------------------------------------------------------------------------------------------

"$ffmpeg/ffmpeg" -y -f concat -safe 0 -i videos.txt -c copy "$3"

#--------------------------------------------------------------------------------------------------
# Clean
#--------------------------------------------------------------------------------------------------

rm videos.txt
