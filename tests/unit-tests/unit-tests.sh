#!/bin/bash

# Update path for OSX systems
GNUBIN="/usr/local/opt/coreutils/libexec/gnubin"
[[ -d "$GNUBIN" ]] && PATH="$GNUBIN:$PATH"

tests_succeded=true
for tst in $(ls $(dirname $0)/test*)
do
    $tst || tests_succeded=false
done

$tests_succeded
