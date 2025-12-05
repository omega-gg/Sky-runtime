#!/bin/sh
set -e

# NOTE Windows: This script makes Ctrl+C functional on a Qt Gui based application under Git bash.

./sky "$@" &

pid=$!

trap "echo 'Ctrl+C detected'; kill -INT $pid" INT

wait $pid
