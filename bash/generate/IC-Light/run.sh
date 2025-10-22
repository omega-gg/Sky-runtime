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

lighting="none"

width="1024"

height="1024"

scale="1.5"

denoise="0.5"

denoise_low="0.9"

#--------------------------------------------------------------------------------------------------
# Syntax
#--------------------------------------------------------------------------------------------------

if [ $# -lt 2 -o $# -gt 9 ]; then

    echo "Usage: run <input> <output> [prompt] [lighting = $lighting] "
    echo "           [width = $width] [height = $height] [scale = $scale] \
[denoise = $denoise] [denoise_low = $denoise_low]"
    echo ""
    echo "lighting: none, left, right, top, bottom"

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# Configuration
#--------------------------------------------------------------------------------------------------

if [ $# -ge 3 ]; then prompt="$3"; fi

if [ $# -ge 4 ]; then lighting="$4"; fi

if [ $# -ge 5 ]; then width="$5"; fi

if [ $# -ge 6 ]; then height="$6"; fi

if [ $# -ge 7 ]; then scale="$7"; fi

if [ $# -ge 8 ]; then denoise="$8"; fi

if [ $# -ge 9 ]; then denoise_low="$9"; fi

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

python - "$1" "$2" "$prompt" "$lighting" "$width" "$height" "$scale" "$denoise" "$denoise_low" << 'PY'
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

# Import IC-Light (foreground-only) module
import gradio_demo as ic

inp, outp, user_prompt, lighting, w, h, scale, denoise, denoise_low = sys.argv[1:10]

def load_rgb(p):
    try:
        return np.array(Image.open(p).convert("RGB"))
    except Exception as e:
        raise SystemExit(f"Error: could not load image '{p}': {e}")

# --- map lighting keyword -> exact BGSource value string ---
LIGHTING_MAP = {
    "none":   ic.BGSource.NONE.value,     # "None"
    "left":   ic.BGSource.LEFT.value,     # "Left Light"
    "right":  ic.BGSource.RIGHT.value,    # "Right Light"
    "top":    ic.BGSource.TOP.value,      # "Top Light"
    "bottom": ic.BGSource.BOTTOM.value,   # "Bottom Light"
}
lighting_key = (lighting or "none").strip().lower()
bg_source_value = LIGHTING_MAP.get(lighting_key, ic.BGSource.NONE.value)

# --- load input and remember original size ---
fg = load_rgb(inp)
orig_w, orig_h = fg.shape[1], fg.shape[0]

# --- working size (no aspect) ---
def snap64(x: int) -> int: return ((x + 63)//64)*64
image_width  = snap64(int(w))
image_height = snap64(int(h))
resize_target = (image_width, image_height)
fg_resized = np.array(Image.fromarray(fg).resize(resize_target, Image.BICUBIC))

# --- params (aligned with gradio_demo defaults) ---
prompt = user_prompt or ""
num_samples = 1
seed = 12345
steps = 25
a_prompt = "best quality"
n_prompt = "lowres, bad anatomy, bad hands, cropped, worst quality"
cfg = 2.0
highres_scale = float(scale)
highres_denoise = float(denoise)
lowres_denoise  = float(denoise_low)

print(f"[IC-Light] Input: {inp}")
print(f"[IC-Light] Output: {outp}")
print(f"[IC-Light] Prompt: {prompt!r}")
print(f"[IC-Light] Lighting: {bg_source_value}")
print(f"[IC-Light] Internal relight resolution: {image_width}x{image_height}, final output: {orig_w}x{orig_h}")

# --- run foreground-conditioned relighting ---
try:
    # process_relight returns (preprocessed_fg, [images...])
    pre_fg, results = ic.process_relight(
        fg_resized, prompt,
        image_width, image_height,
        num_samples, seed, steps,
        a_prompt, n_prompt, cfg,
        highres_scale, highres_denoise, lowres_denoise,
        bg_source_value
    )
except Exception as e:
    raise SystemExit(f"Error during IC-Light inference: {e}")

# --- save first image resized back to original geometry ---
relit = results[0]
relit_resized = np.array(Image.fromarray(relit).resize((orig_w, orig_h), Image.BICUBIC))
Path(outp).parent.mkdir(parents=True, exist_ok=True)
Image.fromarray(relit_resized).save(outp)
print(f"[IC-Light] Saved resized output: {outp}")
PY
