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

IC_Light="${SKY_PATH_IC_LIGHT:-"$SKY_PATH_BIN/IC-Light"}"

image_width="1024"

image_height="1024"

highres_scale="1.5"

highres_denoise="0.5"

#--------------------------------------------------------------------------------------------------
# Syntax
#--------------------------------------------------------------------------------------------------

if [ $# != 3 ]; then

    echo "Usage: transfer <input> <reference> <output>"

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# Environment
#--------------------------------------------------------------------------------------------------

cd "$IC_Light"

if [ -f ".venv/Scripts/activate" ]; then

    # Windows / Git Bash
    . ".venv/Scripts/activate"
else
    . ".venv/bin/activate"
fi

#--------------------------------------------------------------------------------------------------
# Run
#--------------------------------------------------------------------------------------------------

echo "RUNNING IC-Light"

python - "$1" "$2" "$3" "$image_width" "$image_height" "$highres_scale" "$highres_denoise" << 'PY'
import sys
from pathlib import Path
import numpy as np
from PIL import Image

# --- prevent Gradio UI from launching on import ---
import gradio as gr
def _no_launch(*a, **k):
    print("[IC-Light] Gradio UI disabled (headless).")
    return None
gr.Blocks.launch = _no_launch
# --------------------------------------------------

# Import the IC-Light Gradio script as a module (now safe—launch is no-op)
import gradio_demo_bg as ic  # uses ic.BGSource, ic.process_relight, globals set up at import

inp, ref, outp, w, h, scale, denoise = sys.argv[1:8]

def load_rgb(p):
    try:
        return np.array(Image.open(p).convert("RGB"))
    except Exception as e:
        raise SystemExit(f"Error: could not load image '{p}': {e}")

fg = load_rgb(inp)
bg = load_rgb(ref)

# Default params matching the Gradio UI defaults
prompt = ""
image_width = int(w)
image_height = int(h)
num_samples = 1
seed = 12345
steps = 20
a_prompt = "best quality"
n_prompt = "lowres, bad anatomy, bad hands, cropped, worst quality"
cfg = 7.0
highres_scale = float(scale)
highres_denoise = float(denoise)
bg_source = ic.BGSource.UPLOAD.value # use the provided background as-is

print(f"[IC-Light] Input: {inp}\n[IC-Light] Background: {ref}\n[IC-Light] Output: {outp}")
print(f"[IC-Light] Resolution: {image_width}x{image_height}")

# Run background-conditioned relighting
try:
    results = ic.process_relight(
        fg, bg, prompt,
        image_width, image_height,
        num_samples, seed, steps,
        a_prompt, n_prompt, cfg,
        highres_scale, highres_denoise,
        bg_source
    )
except Exception as e:
    raise SystemExit(f"Error during IC-Light inference: {e}")

# results = [relit_img(s)..., fg_preview, bg_preview]; take first relit image
relit = results[0]

Path(outp).parent.mkdir(parents=True, exist_ok=True)
Image.fromarray(relit).save(outp)
print(f"[IC-Light] Saved: {outp}")
PY
