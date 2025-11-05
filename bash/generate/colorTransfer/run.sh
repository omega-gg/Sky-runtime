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

color_transfer="${SKY_PATH_COLOR_TRANSFER:-"$SKY_PATH_BIN/color_transfer"}"

#--------------------------------------------------------------------------------------------------
# Syntax
#--------------------------------------------------------------------------------------------------

if [ $# != 3 ]; then

    echo "Usage: run <input> <reference> <output>"

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# Environment
#--------------------------------------------------------------------------------------------------

cd "$color_transfer"

if [ -f ".venv/Scripts/activate" ]; then

    # Windows / Git Bash
    . ".venv/Scripts/activate"
else
    . ".venv/bin/activate"
fi

#--------------------------------------------------------------------------------------------------
# Run
#--------------------------------------------------------------------------------------------------

echo "RUNNING color_transfer"

python - "$1" "$2" "$3" << 'PY'
import sys, cv2, numpy as np
from color_transfer import color_transfer

inp, ref, out = sys.argv[1:4]

# Load with alpha support
src = cv2.imread(inp, cv2.IMREAD_UNCHANGED)
if src is None:
    raise SystemExit(f"Error: could not load input image '{inp}'")

refimg = cv2.imread(ref, cv2.IMREAD_UNCHANGED)
if refimg is None:
    raise SystemExit(f"Error: could not load reference image '{ref}'")

# Separate alpha if present
def split_alpha(img):
    if img.ndim == 2:
        return cv2.cvtColor(img, cv2.COLOR_GRAY2BGR), None
    if img.shape[2] == 4:
        return img[:, :, :3], img[:, :, 3]
    return img, None

src_rgb, src_alpha = split_alpha(src)
ref_rgb, _ = split_alpha(refimg)

# Apply color transfer
res_rgb = color_transfer(ref_rgb, src_rgb)

# Reattach alpha if it existed
if src_alpha is not None:
    res = np.dstack([res_rgb, src_alpha])
else:
    res = res_rgb

if not cv2.imwrite(out, res):
    raise SystemExit(f"Error: failed to write output '{out}'")
print(f"Saved: {out}")
PY
