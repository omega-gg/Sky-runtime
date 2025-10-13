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
# https://fal.ai/models/fal-ai/flux-pro/kontext/api

api_pro="https://fal.run/fal-ai/flux-pro/kontext"
api_max="https://fal.run/fal-ai/flux-pro/kontext/max"

fal_key="$FAL_KEY"

#--------------------------------------------------------------------------------------------------
# Amazon S3

# NOTE: This script depends on:
#       AWS_ACCESS_KEY_ID
#       AWS_SECRET_ACCESS_KEY
#       AWS_DEFAULT_REGION

s3="s3://omega.gg"

s3_path="upload"

s3_url="https://s3-eu-west-1.amazonaws.com/omega.gg/$s3_path"

#--------------------------------------------------------------------------------------------------
# Functions
#--------------------------------------------------------------------------------------------------

run()
{
    curl --request POST --url "$api"               \
         --header "Content-Type: application/json" \
         --header "Authorization: Key $fal_key" \
         --data @data.txt
}

getData()
{
    if [ -n "$AWS_ACCESS_KEY_ID" ]; then

        local filename=$(basename -- "$1")

        aws s3 cp --quiet --acl public-read "$1" "$s3/$s3_path/$filename"

        echo "$s3_url/$filename"
    else
        local mime=$(file --brief --mime-type "$1")

        echo "data:$mime;base64,$(base64 -w 0 "$1")"
    fi
}

removeData()
{
    if [ -z "$AWS_ACCESS_KEY_ID" ]; then

        return
    fi

    local filename=$(basename -- "$1")

    aws s3 rm --quiet "$s3/$s3_path/$filename"
}

#--------------------------------------------------------------------------------------------------
# Syntax
#--------------------------------------------------------------------------------------------------

if [ $# -lt 3 -o $# -gt 4 ] || [ $# = 4 -a "$4" != "max" ]; then

    echo "Usage: kontext <image input> <image output> <prompt> [max]"

    exit 1
fi

if [ -z "$fal_key" ]; then

    echo "kontext: FAL_KEY is missing in the environment."

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# Configuration
#--------------------------------------------------------------------------------------------------

if [ $# = 4 ]; then

    api="$api_max"
else
    api="$api_pro"
fi

#--------------------------------------------------------------------------------------------------
# Run
#--------------------------------------------------------------------------------------------------

cat > data.txt <<EOF
{
    "image_url": "$(getData "$1")",
    "output_format": "png",
    "prompt": "$3"
}
EOF

cat data.txt

data=$(run)

echo "$data"

rm data.txt

url=$(echo "$data" | grep -o '"url":"[^"]*' | grep -o '[^"]*$')

curl --ssl-no-revoke -L -o "$2" "$url"

#--------------------------------------------------------------------------------------------------
# Clean
#--------------------------------------------------------------------------------------------------

removeData "$1"
