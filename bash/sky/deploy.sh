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
# Settings
#--------------------------------------------------------------------------------------------------
# environment

qt="qt6"

#--------------------------------------------------------------------------------------------------
# Functions
#--------------------------------------------------------------------------------------------------

copyFolder()
{
    $find "$1" -type f -iname "$3" | while read -r file; do

        folder="${file#$1/}"

        if [ "$folder" = "${folder%/*}" ]; then

            folder="$2/."
        else
            folder="$2/${folder%/*}"
        fi

        mkdir -p "$folder"

        output="$folder/${file##*/}"

        cp "$file" "$output"

        if [ "$4" != "" ]; then

            chmod "$4" "$output"
        fi
    done
}

copyFolderLite()
{
    mkdir -p "$2"

    $find "$1" -maxdepth 1 -type f -iname "$3" | while read -r file; do

        name="${file##*/}"

        output="$2/$name"

        cp "$file" "$output"

        if [ "$4" != "" ]; then

            chmod "$4" "$output"
        fi
    done
}

generateQml()
{
    if [ $qt = "qt4" ]; then

        defines="QT_4 QT_OLD"

    elif [ $qt = "qt5" ]; then

        defines="QT_5 QT_OLD QT_NEW"
    else
        defines="QT_6 QT_NEW"
    fi

    if [ $1 = "win32" -o $1 = "win64" ]; then

        defines="$defines DESKTOP WINDOWS WINDOW_NATIVE"

    elif [ $1 = "macOS" ]; then

        defines="$defines DESKTOP MAC"

    elif [ $1 = "iOS" ]; then

        defines="$defines MOBILE IOS NO_TORRENT"

    elif [ $1 = "linux" ]; then

        defines="$defines DESKTOP LINUX"
    else
        defines="$defines MOBILE ANDROID"
    fi

    defines="$defines DEPLOY"

    "$SKY_PATH_RUNTIME"/qmlGenerator "$2" "$2" "$defines"
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

if [ $# != 3 -a $# != 4 ] \
   || \
   [ $1 != "win32" -a $1 != "win64" -a $1 != "macOS" -a $1 != "iOS" -a $1 != "linux" -a \
     $1 != "android" ] \
   || \
   [ $# = 4 -a "$4" != "src" -a "$4" != "all" ]; then

    echo "Usage: deploy <win32 | win64 | macOS | iOS | linux | android>"
    echo "              <folder> <name> [src | all]"
    echo ""
    echo "example:"
    echo "    deploy linux path/to/turbopixel turbopixel"

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# Configuration
#--------------------------------------------------------------------------------------------------

if [ -z "$SKY_PATH_RUNTIME" ]; then

    echo "SKY_PATH_RUNTIME is not set" >&2

    exit 1
fi

skz="$(getSky)/../skz"

input=$(getPath "$2")

# NOTE windows: Ensure we use the proper find.
if [ -x /usr/bin/find ]; then

    find="/usr/bin/find"
else
    find="find"
fi

run="$skz/run"

src="$skz/src/$3"

bash="$skz/bash/$3"

locale="$skz/locale/$3"

doc="$skz/doc/$3"

if [ "$4" = "src" -o "$4" = "all" ]; then

    copy="src"
else
    copy="default"
fi

#--------------------------------------------------------------------------------------------------
# Create folder
#--------------------------------------------------------------------------------------------------

echo "DEPLOYING $3"

temp="$run/temp"

mkdir -p "$temp"

if [ $copy = "src" ]; then

    mkdir -p "$src"
fi

if [ "$4" = "all" ]; then

    mkdir -p "$bash"
    mkdir -p "$locale"
    mkdir -p "$doc"
fi

#--------------------------------------------------------------------------------------------------
# Deploy
#--------------------------------------------------------------------------------------------------

if [ $copy = "src" ]; then

    copyFolder "$input/src" "$src" "*.qml" "+x"

    cp -f "$input/src/qmldir" "$src"

    generateQml $1 "$src"
fi

if [ "$4" = "all" ]; then

    copyFolder "$input/bash"   "$bash"   "*.sh"  "+x"
    copyFolder "$input/locale" "$locale" "*.qm"
    copyFolder "$input"        "$doc"    "*.md"
fi

# NOTE: Copy .sky(s) at the end so we trigger the reload in Sky-runtime after copying everything.
copyFolderLite "$input/run" "$temp" "*.sky" "+x"

generateQml $1 "$temp"

mv "$temp"/* "$run"

rm -rf "$temp"

#--------------------------------------------------------------------------------------------------
# Clean files
#--------------------------------------------------------------------------------------------------

# NOTE: Convert Windows CRLF line endings to Unix LF.

$find "$run" -type f \( -iname "$3*.sky" \) -exec perl -i -pe 's/\r//g' {} +

if [ $copy = "src" ]; then

    $find "$src" -type f \( -iname "*.qml" \) -exec perl -i -pe 's/\r//g' {} +
fi

if [ "$4" = "all" ]; then

    $find "$bash" -type f \( -iname "*.sh" \) -exec perl -i -pe 's/\r//g' {} +
fi

#--------------------------------------------------------------------------------------------------
# Clean
#--------------------------------------------------------------------------------------------------

if [ $copy = "src" ]; then

    set +e

    rmdir "$src" 2>/dev/null

    set -e
fi

if [ "$4" = "all" ]; then

    set +e

    rmdir "$bash"   2>/dev/null
    rmdir "$locale" 2>/dev/null
    rmdir "$doc"    2>/dev/null

    set -e
fi
