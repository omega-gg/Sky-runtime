#!/bin/sh
set -e

#--------------------------------------------------------------------------------------------------
# Settings
#--------------------------------------------------------------------------------------------------
# https://docs.freepik.com/api-reference/image-relight/post-image-relight

api="https://api.freepik.com/v1/ai/image-relight"

freepik_key="$FREEPIK_KEY"

style="standard"
# Available options:
# standard,
# darker_but_realistic,
# clean,
# smooth,
# brighter,
# contrasted_n_hdr,
# just_composition

light_transfer_strength="100"

change_background="false"

#--------------------------------------------------------------------------------------------------
# Functions
#--------------------------------------------------------------------------------------------------

run()
{
    curl --request POST --url "$api" --ssl-no-revoke \
         --header "Content-Type: application/json"   \
         --header "x-freepik-api-key: $freepik_key"  \
         --data @data.txt
}

get()
{
    curl --request GET --url "$api/$1" --ssl-no-revoke \
         --header "x-freepik-api-key: $freepik_key"
}

#--------------------------------------------------------------------------------------------------
# Syntax
#--------------------------------------------------------------------------------------------------

if [ $# -lt 3 -o $# -gt 6 ]; then

    echo "Usage: relight <image input> <image reference> <image output>"
    echo "               [style = standard] [light_transfer_strength = 100]"
    echo "               [change_background = false]"
    echo ""
    echo "style: standard"
    echo "       darker_but_realistic"
    echo "       clean"
    echo "       smooth"
    echo "       brighter"
    echo "       contrasted_n_hdr"
    echo "       just_composition"

    exit 1
fi

if [ -z "$freepik_key" ]; then

    echo "relight: FREEPIK_KEY is missing in the environment."

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# Configuration
#--------------------------------------------------------------------------------------------------

if [ $# -gt 3 ]; then

    style="$4"
fi

if [ $# -gt 4 ]; then

    light_transfer_strength="$5"
fi

if [ $# -gt 5 ]; then

    change_background="$6"
fi

#--------------------------------------------------------------------------------------------------
# Run
#--------------------------------------------------------------------------------------------------

cat > data.txt <<EOF
{
    "image": "$(base64 "$1")",
    "transfer_light_from_reference_image": "$(base64 "$2")",
    "light_transfer_strength": $light_transfer_strength,
    "change_background": $change_background,
    "style": "$style"
}
EOF

data=$(run)

echo "$data"

rm data.txt

id=$(echo "$data" | grep -o '"task_id":"[^"]*' | grep -o '[^"]*$')

while :
do
    sleep 10

    data=$(get "$id")

    echo "$data"

    status=$(echo "$data" | grep -o '"status":"[^"]*' | grep -o '[^"]*$')

    if [ "$status" != "COMPLETED" ]; then

        continue
    fi

    url=$(echo "$data" | grep -o '"generated":\["[^"]*' | grep -o '[^"]*$')

    break
done

curl -L -o "$3" "$url"
