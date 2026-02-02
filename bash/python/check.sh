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

bin="${SKY_PATH_PYTHON:-"$SKY_PATH_BIN/python"}"

version="3.14.2"

#--------------------------------------------------------------------------------------------------
# Check
#--------------------------------------------------------------------------------------------------

case `uname` in
MINGW*) os="windows";;
*)      os="other";;
esac

if [ $os = "windows" ]; then

    python="$bin/python.exe"
else
    python="$bin/bin/python3"
fi

if [ -f "$python" ]; then

    current="$("$python" - <<EOF
import sys
print("{}.{}.{}".format(*sys.version_info[:3]))
EOF
)"

    if [ "$version" = "$current" ]; then

        echo "Python $version is already installed."

        exit 0
    fi
fi

exit 1
