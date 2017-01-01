#!/bin/bash

# Update path for OSX systems
GNUBIN="/usr/local/opt/coreutils/libexec/gnubin"
[[ -d "$GNUBIN" ]] && PATH="$GNUBIN:$PATH"

source "$(dirname $0)/../utils/utils.sh"

# Disable the exiterr
set +e

function oneTimeSetUp(){
    setUpUnitTests
}

function test_check_no_tabs(){
    # This is the OSX illness. Apparentely,
    # specifying directly \t character in grep command
    # could not work in OSX.
    assertCommandFailOnStatus 1 grep -R "$(printf '\t')" $(dirname $0)/../../bin/*
    assertEquals "" "$(cat $STDOUTF)"
    assertEquals "" "$(cat $STDERRF)"
    assertCommandFailOnStatus 1 grep -R "$(printf '\t')" $(dirname $0)/../../lib/*
    assertEquals "" "$(cat $STDOUTF)"
    assertEquals "" "$(cat $STDERRF)"
}

source $(dirname $0)/../utils/shunit2
