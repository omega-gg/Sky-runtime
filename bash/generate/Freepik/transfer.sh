#!/bin/sh
set -e

#--------------------------------------------------------------------------------------------------
# Settings
#--------------------------------------------------------------------------------------------------
# https://docs.freepik.com/api-reference/image-style-transfer/post-image-style-transfer

api="https://api.freepik.com/v1/ai/image-style-transfer"

freepik_key="$FREEPIK_KEY"

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

if [ $# != 3 ]; then

    echo "Usage: transfer <image input> <image reference> <image output>"

    exit 1
fi

if [ -z "$freepik_key" ]; then

    echo "transfer: FREEPIK_KEY is missing in the environment."

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# Run
#--------------------------------------------------------------------------------------------------

cat > data.txt <<EOF
{
    "image": "$(base64 "$1")",
    "reference_image": "$(base64 "$2")"
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
