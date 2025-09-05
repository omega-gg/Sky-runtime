#!/bin/sh
set -e

#--------------------------------------------------------------------------------------------------
# Settings
#--------------------------------------------------------------------------------------------------

FaceFusion="$PWD/bin/facefusion"

#--------------------------------------------------------------------------------------------------
# pinokio

pinokio="false"

pinokio_path="/c/pinokio/api/facefusion-pinokio.git"

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

    FaceFusion="$pinokio_path/facefusion"

    export PATH="$pinokio_path/.env:$pinokio_path/.env/Library/bin:$PATH"
fi

cd "$FaceFusion"

python facefusion.py headless-run \
    --target-path "$1" \
    --source-paths "$2" \
    --output-path "$3" \
    --face-swapper-model hyperswap_1a_256 \
    --face-swapper-pixel-boost 1024x1024 \
    --output-image-quality 100
