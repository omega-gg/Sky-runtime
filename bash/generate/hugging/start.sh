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
# https://huggingface.co/docs/hub/en/api

api="https://api.endpoints.huggingface.cloud/v2/endpoint"

key="$HUGGING_KEY"

#--------------------------------------------------------------------------------------------------
# Functions
#--------------------------------------------------------------------------------------------------

run()
{
    curl --request POST --url "$api/$1/resume" --ssl-no-revoke \
         --header "Content-Type: application/json"            \
         --header "Authorization: Bearer $key"
}

get()
{
    curl --request GET --url "$api/$1" --ssl-no-revoke \
         --header "Authorization: Bearer $key"
}

#--------------------------------------------------------------------------------------------------
# Syntax
#--------------------------------------------------------------------------------------------------

if [ $# != 1 ]; then

    echo "Usage: start <user/endpoint>"
    echo ""
    echo "example:"
    echo "    start 3unjee/qwen-angle-end"

    exit 1
fi

if [ -z "$key" ]; then

    echo "qwenAngle: HUGGING_KEY is missing in the environment."

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# Run
#--------------------------------------------------------------------------------------------------

run "$1"

while :
do
    data=$(get "$1")

    state=$(echo "$data" | grep -o '"state":"[^"]*' | grep -o '[^"]*$')

    if [ "$state" = "running" ]; then

        echo "Endpoint is running."

        exit 0

    elif [ "$state" = "failed" ] || [ "$state" = "error" ] || [ "$state" = "stopped" ]; then

        echo "Endpoint $state. Exiting."

        exit 1
    fi

    sleep 5
done
