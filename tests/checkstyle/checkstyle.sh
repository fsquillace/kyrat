#!/bin/bash
source "$(dirname $0)/../utils/utils.sh"

# Disable the exiterr
set +e

function oneTimeSetUp(){
    setUpUnitTests
}

function test_check_no_tabs(){
    assertCommandFailOnStatus 1 grep -R -P "\t" bin/*
    assertEquals "" "$(cat $STDOUTF)"
    assertEquals "" "$(cat $STDERRF)"
    assertCommandFailOnStatus 1 grep -R -P "\t" lib/*
    assertEquals "" "$(cat $STDOUTF)"
    assertEquals "" "$(cat $STDERRF)"
}

source $(dirname $0)/../utils/shunit2
