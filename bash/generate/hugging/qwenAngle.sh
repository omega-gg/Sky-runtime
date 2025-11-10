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
# https://huggingface.co/3unjee/qwen-angle

root="$(dirname "$0")"

api="$HUGGING_QWEN_ANGLE_ENDPOINT"

token="$HUGGING_QWEN_ANGLE_TOKEN"

ffmpeg="${SKY_PATH_FFMPEG:-"$SKY_PATH_BIN/ffmpeg"}"

ffprobe="${SKY_PATH_FFPROBE:-"$SKY_PATH_BIN/ffprobe"}"

resize="$root/../../image/resize.sh"

#--------------------------------------------------------------------------------------------------
# Functions
#--------------------------------------------------------------------------------------------------

run()
{
    curl --request POST --url "$api" --ssl-no-revoke \
         --header "Content-Type: application/json"   \
         --header "Authorization: Bearer $token"     \
         --data @data.txt
}

get()
{
    curl --request GET --url "$api/$1" --ssl-no-revoke \
         --header "Authorization: Bearer $token"
}

getWidth()
{
    "$ffprobe" -v error -select_streams v:0 -show_entries stream=width -of csv=p=0 "$1"
}

getHeight()
{
    "$ffprobe" -v error -select_streams v:0 -show_entries stream=height -of csv=p=0 "$1"
}

#--------------------------------------------------------------------------------------------------
# Syntax
#--------------------------------------------------------------------------------------------------

if [ $# != 3 ]; then

    echo "Usage: qwenAngle <image input> <image output> <prompt>"
    echo ""
    echo "example:"
    echo "    qwenAngle input.png output.png 'rotate the camera 45 degrees to the left'"

    exit 1
fi

if [ -z "$api" ]; then

    echo "qwenAngle: HUGGING_QWEN_ANGLE_ENDPOINT is missing in the environment."

    exit 1
fi

if [ -z "$token" ]; then

    echo "qwenAngle: HUGGING_QWEN_ANGLE_TOKEN is missing in the environment."

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# Configuration
#--------------------------------------------------------------------------------------------------

width=$(getWidth "$1")

height=$(getHeight "$1")

#--------------------------------------------------------------------------------------------------
# Run
#--------------------------------------------------------------------------------------------------

temp="$root/temp.png"

size="1600"

# Max 1024x1024, preserve aspect, no padding, high-quality scaling
"$ffmpeg" -y -i "$1" \
  -vf "scale=w='ceil(iw*min($size/iw,$size/ih))':h='ceil(ih*min($size/iw,$size/ih))':force_original_aspect_ratio=decrease:flags=lanczos" \
  "$temp"

cat > data.txt <<EOF
{
    "inputs":
    {
        "image": "$(base64 "$temp")",
        "rotate_deg": "-90",
        "move_forward": 0,
        "vertical_tilt": 0,
        "wideangle": false,
        "seed": 0,
        "randomize_seed": true,
        "true_guidance_scale": 1.0,
        "num_inference_steps": 4,
        "width": "$(getWidth "$temp")",
        "height": "$(getHeight "$temp")"
    }
}
EOF

data=$(run)

echo "$data"

rm data.txt

rm "$temp"

data=$(echo "$data" | grep -o '"image_base64":"[^"]*' | sed 's/"image_base64":"//')

echo "$data" | base64 -d > "$2"
