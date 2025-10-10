#!/bin/sh
set -e

#--------------------------------------------------------------------------------------------------
# Settings
#--------------------------------------------------------------------------------------------------

FaceFusion="${SKY_PATH_FACE_FUSION:-"$PWD/../../../user/bin/facefusion"}"

#--------------------------------------------------------------------------------------------------
# pinokio

pinokio="false"

# "/c/pinokio/api"
pinokio_path="$SKY_PATH_PINOKIO"

#--------------------------------------------------------------------------------------------------
# Syntax
#--------------------------------------------------------------------------------------------------

if [ $# != 3 ]; then

    echo "Usage: swap <input> <reference> <output>"

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# Run
#--------------------------------------------------------------------------------------------------

if [ $pinokio = "true" ]; then

    echo "swap: Using pinokio"

    path="$pinokio_path/facefusion-pinokio.git"

    FaceFusion="$path/facefusion"

    export PATH="$path/.env:$path/.env/Library/bin:$PATH"
fi

cd "$FaceFusion"

python facefusion.py headless-run \
    --target-path "$1" \
    --source-paths "$2" \
    --output-path "$3" \
    --face-swapper-model hyperswap_1a_256 \
    --face-swapper-pixel-boost 1024x1024 \
    --output-image-quality 100
