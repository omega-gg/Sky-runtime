#!/bin/sh
set -e

#--------------------------------------------------------------------------------------------------
# Settings
#--------------------------------------------------------------------------------------------------

ffmpeg="$PWD/../ffmpeg/bin/ffmpeg"

filter="bilinear"

#--------------------------------------------------------------------------------------------------
# Syntax
#--------------------------------------------------------------------------------------------------

if [ $# != 4 -a $# != 5 ]; then

    echo "Usage: resize <input> <output> <width> <height> [filter = bilinear]"
    echo ""
    echo "filter: fast_bilinear"
    echo "        bilinear"
    echo "        bicubic"
    echo "        experimental"
    echo "        neighbor"
    echo "        area"
    echo "        bicublin"
    echo "        gauss"
    echo "        sinc"
    echo "        lanczos"
    echo "        spline"
    echo "        print_info"
    echo "        accurate_rnd"
    echo "        full_chroma_int"
    echo "        full_chroma_inp"
    echo "        bitexact"
    echo "        unstable"

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# Configuration
#--------------------------------------------------------------------------------------------------

if [ $# -gt 4 ]; then

    filter="$5"
fi

#--------------------------------------------------------------------------------------------------
# Run
#--------------------------------------------------------------------------------------------------

"$ffmpeg" -y -i "$1" -vf "scale=$3:$4:flags=$filter" "$2"
