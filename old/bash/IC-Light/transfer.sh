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

prompt=""

width="1024"

height="1024"

scale="1.5"

denoise="0.5"

#--------------------------------------------------------------------------------------------------
# Syntax
#--------------------------------------------------------------------------------------------------

if [ $# -lt 3 -o $# -gt 8 ]; then

    echo "Usage: transfer <input> <reference> <output> [prompt] "
    echo "                [width = $width] [height = $height] [scale = $scale] \
[denoise = $denoise]"

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# Configuration
#--------------------------------------------------------------------------------------------------

if [ $# -ge 3 ]; then prompt="$3"; fi

if [ $# -ge 4 ]; then width="$4"; fi

if [ $# -ge 5 ]; then height="$5"; fi

if [ $# -ge 6 ]; then scale="$6"; fi

if [ $# -ge 7 ]; then denoise="$7"; fi

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

python - "$1" "$2" "$3" "$prompt" "$width" "$height" "$scale" "$denoise" << 'PY'
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

# Import IC-Light module
import gradio_demo_bg as ic

inp, ref, outp, user_prompt, w, h, scale, denoise = sys.argv[1:9]

def load_rgb(p):
    try:
        return np.array(Image.open(p).convert("RGB"))
    except Exception as e:
        raise SystemExit(f"Error: could not load image '{p}': {e}")

# --- load and remember original size ---
fg = load_rgb(inp)
bg = load_rgb(ref)
orig_w, orig_h = fg.shape[1], fg.shape[0]

# --- resize both to image_width × image_height (no aspect ratio) ---
def snap64(x: int) -> int: return ((x + 63)//64)*64
image_width  = snap64(int(w))
image_height = snap64(int(h))
resize_target = (image_width, image_height)
fg_resized = np.array(Image.fromarray(fg).resize(resize_target, Image.BICUBIC))
bg_resized = np.array(Image.fromarray(bg).resize(resize_target, Image.BICUBIC))

# --- IC-Light params ---
prompt = user_prompt
num_samples = 1
seed = 12345
steps = 20
a_prompt = "best quality"
n_prompt = "lowres, bad anatomy, bad hands, cropped, worst quality"
cfg = 7.0
highres_scale = float(scale)
highres_denoise = float(denoise)
bg_source = ic.BGSource.UPLOAD.value

print(f"[IC-Light] Input: {inp}\n[IC-Light] Background: {ref}\n[IC-Light] Output: {outp}")
print(f"[IC-Light] Internal relight resolution: {image_width}x{image_height}, final output: {orig_w}x{orig_h}")

# --- run relighting ---
try:
    results = ic.process_relight(
        fg_resized, bg_resized, prompt,
        image_width, image_height,
        num_samples, seed, steps,
        a_prompt, n_prompt, cfg,
        highres_scale, highres_denoise,
        bg_source
    )
except Exception as e:
    raise SystemExit(f"Error during IC-Light inference: {e}")

# --- restore original geometry ---
relit = results[0]
relit_resized = np.array(Image.fromarray(relit).resize((orig_w, orig_h), Image.BICUBIC))

Path(outp).parent.mkdir(parents=True, exist_ok=True)
Image.fromarray(relit_resized).save(outp)
print(f"[IC-Light] Saved resized output: {outp}")
PY
