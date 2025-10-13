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

rembg="${SKY_PATH_REMBG:-"$PWD/../../../user/bin/rembg"}"

model="birefnet-general"

#--------------------------------------------------------------------------------------------------
# Syntax
#--------------------------------------------------------------------------------------------------

if [ $# != 2 -a $# != 3 ]; then

    echo "Usage: run <input> <output> [model = birefnet-general]"
    echo ""
    echo "model: u2net                    standard general model"
    echo "       u2netp                   lightweight general model"
    echo "       u2net_human_seg          tuned for humans"
    echo "       u2net_cloth_seg          tuned for clothing"
    echo "       silueta                  compact silhouette model"
    echo "       isnet-general-use        general segmentation"
    echo "       isnet-anime              for anime / stylized images"
    echo "       sam                      Segment Anything Model"
    echo "       birefnet-general         BiRefNet general model"
    echo "       birefnet-general-lite    lighter version of BiRefNet"
    echo "       birefnet-portrait        BiRefNet tuned for portrait"
    echo "       birefnet-dis             Difficult Image Segmentation"
    echo "       birefnet-hrsod           High Resolution Salient Object Detection"
    echo "       birefnet-cod             Camouflaged Object Detection"
    echo "       birefnet-massive         highest fidelity segmentation"

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# Configuration
#--------------------------------------------------------------------------------------------------

if [ $# = 3 ]; then

    model="$3"
fi

#--------------------------------------------------------------------------------------------------
# Environment
#--------------------------------------------------------------------------------------------------

cd $rembg

if [ -f ".venv/Scripts/activate" ]; then

    # Windows / Git Bash
    . ".venv/Scripts/activate"
else
    . ".venv/bin/activate"
fi

#--------------------------------------------------------------------------------------------------
# Run
#--------------------------------------------------------------------------------------------------

echo "RUNNING rembg with '$model' model"

rembg i -m "$model" "$1" "$2"
