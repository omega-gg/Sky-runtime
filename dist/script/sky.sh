#!/bin/sh
set -e

# NOTE Windows: This script makes Ctrl+C functional under Git bash.

./sky "$@" &

pid=$!

trap "echo 'Ctrl+C detected'; kill -INT $pid" INT

code=0

wait $pid || code=$?

trap - INT

exit $code
