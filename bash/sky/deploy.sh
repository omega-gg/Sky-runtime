#!/bin/sh
set -e
#==================================================================================================
#
#   Copyright (C) 2015-2026 Sky kit authors. <http://omega.gg/Sky>
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

copyFolder()
{
    $find "$1" -type f -iname "$3" | while read -r file; do

        folder="${file#$1/}"

        folder="$2/$(dirname "$folder")"

        mkdir -p "$folder"

        output="$folder/$(basename "$file")"

        cp "$file" "$output"

        if [ "$4" != "" ]; then

            chmod "$4" "$output"
        fi
    done
}

getSky()
{
    if [ -z "$SKY_PATH_BIN" ]; then

        echo "SKY_PATH_BIN is not set" >&2

        return
    fi

    case `uname` in
        MINGW*|MSYS*|CYGWIN*)
            cygpath -u "$SKY_PATH_BIN/gg.omega";;
        *)
            echo "$SKY_PATH_BIN/gg.omega";;
    esac
}

getPath()
{
    path="$1"

    if [ "${path#/}" = "$path" ] && [ "${path#?:[\\/]}" = "$path" ]; then

        echo "$PWD/$path"
    else
        echo "$path"
    fi
}

#--------------------------------------------------------------------------------------------------
# Syntax
#--------------------------------------------------------------------------------------------------

if [ $# != 2 -a $# != 3 ] || [ $# = 3 -a "$3" != "all" ]; then

    echo "Usage: deploy <folder> <name> [all]"
    echo ""
    echo "example:"
    echo "    deploy path/to/turbopixel turbopixel"

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# Configuration
#--------------------------------------------------------------------------------------------------

skz="$(getSky)/../skz"

input=$(getPath "$1")

# NOTE windows: Ensure we use the proper find.
if [ -x /usr/bin/find ]; then

    find="/usr/bin/find"
else
    find="find"
fi

run="$skz/run"

src="$skz/src/$2"

bash="$skz/bash/$2"

locale="$skz/locale/$2"

doc="$skz/doc/$2"

#--------------------------------------------------------------------------------------------------
# Create folder
#--------------------------------------------------------------------------------------------------

echo "DEPLOYING $2"

mkdir -p "$run"
mkdir -p "$src"

if [ "$3" = "all" ]; then

    mkdir -p "$bash"
    mkdir -p "$locale"
    mkdir -p "$doc"
fi

#--------------------------------------------------------------------------------------------------
# Deploy
#--------------------------------------------------------------------------------------------------

copyFolder "$input/run" "$run" "*.sky" "+x"
copyFolder "$input/src" "$src" "*.qml" "+x"

cp -f "$input/src/qmldir" "$src"

if [ "$3" = "all" ]; then

    copyFolder "$input/bash"   "$bash"   "*.sh"  "+x"
    copyFolder "$input/locale" "$locale" "*.qm"
    copyFolder "$input"        "$doc"    "*.md"

    cp -f "$input"/*.md "$doc"
fi

#--------------------------------------------------------------------------------------------------
# Clean files
#--------------------------------------------------------------------------------------------------

# NOTE: Convert Windows CRLF line endings to Unix LF.

$find "$run" -type f \( -iname "$2*.sky" \) -exec perl -i -pe 's/\r//g' {} +
$find "$src" -type f \( -iname "*.qml"   \) -exec perl -i -pe 's/\r//g' {} +

if [ "$3" = "all" ]; then

    $find "$bash" -type f \( -iname "*.sh" \) -exec perl -i -pe 's/\r//g' {} +
fi

#--------------------------------------------------------------------------------------------------
# Clean
#--------------------------------------------------------------------------------------------------

set +e

rmdir "$src" 2>/dev/null

if [ "$3" = "all" ]; then

    rmdir "$bash"   2>/dev/null
    rmdir "$locale" 2>/dev/null
    rmdir "$doc"    2>/dev/null
fi

set -e
