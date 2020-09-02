#!/bin/bash

source "$(dirname $0)/../utils/utils.sh"

# Disable the exiterr
set +e

function oneTimeSetUp(){
    setUpUnitTests
}

function setUp(){
    source "$(dirname $0)/../../lib/core.sh"
    kyratSetUp
}

function tearDown(){
    kyratTearDown
}

function _wrap_parse_args(){
    _parse_args "$@"
    echo "${SSH_OPTS[@]}"
    echo "${COMMANDS[@]}"
}

function test_concatenate_files_null(){
    assertCommandSuccess _concatenate_files
    assertEquals "" "$(cat $STDOUTF)"
}

function test_concatenate_files_empty_directory(){
    mkdir $KYRAT_HOME/mydir
    echo "this is a file" > $KYRAT_HOME/myfile
    assertCommandSuccess _concatenate_files $KYRAT_HOME/myfile $KYRAT_HOME/mydir/*
    assertEquals "this is a file" "$(cat $STDOUTF)"
}

function test_concatenate_files_not_existing_directory(){
    assertCommandSuccess _concatenate_files $KYRAT_HOME/mydir/*
    assertEquals "" "$(cat $STDOUTF)"
    assertEquals "" "$(cat $STDERRF)"
}

function test_concatenate_files_with_directory(){
    mkdir $KYRAT_HOME/mydir
    assertCommandSuccess _concatenate_files $KYRAT_HOME/mydir
    assertEquals "" "$(cat $STDOUTF)"
    assertEquals "Warn: $KYRAT_HOME/mydir is not a file." "$(cat $STDERRF)"
}

function test_concatenate_files(){
    mkdir $KYRAT_HOME/mydir
    echo "this is a file" > $KYRAT_HOME/myfile
    echo "this is another file" > $KYRAT_HOME/mydir/myfile
    assertCommandSuccess _concatenate_files $KYRAT_HOME/myfile $KYRAT_HOME/mydir/*
    assertEquals "$(echo -e "this is a file\nthis is another file")" "$(cat $STDOUTF)"
}

function test_parse_args_no_args(){
    ssh_func() {
        return 11
    }
    SSH=ssh_func
    assertCommandFailOnStatus 11 _parse_args
}

function test_parse_args_no_commands(){
    assertCommandSuccess _wrap_parse_args -t -o "bla bla" -p localhost
    assertEquals "-t -o bla bla -p localhost" "$(cat $STDOUTF)"
}

function test_parse_args_no_opts(){
    assertCommandSuccess _wrap_parse_args -- ls -lhr -t
    assertEquals "$(echo -e "\nls -lhr -t")" "$(cat $STDOUTF)"
}

function test_parse_args(){
    assertCommandSuccess _wrap_parse_args -t localhost -- ls -lhr -t
    assertEquals "$(echo -e "-t localhost\nls -lhr -t")" "$(cat $STDOUTF)"
}

function test_kyrat(){
    _parse_args(){
        echo "parse $@"
    }
    _execute_ssh(){
        echo "execute"
    }
    assertCommandSuccess kyrat localhost
    assertEquals "$(echo -e "parse localhost\nexecute")" "$(cat $STDOUTF)"
    [[ -d $KYRAT_HOME/bashrc.d ]]
    assertEquals 0 $?
    [[ -d $KYRAT_HOME/zshrc.d ]]
    assertEquals 0 $?
    [[ -d $KYRAT_HOME/inputrc.d ]]
    assertEquals 0 $?
    [[ -d $KYRAT_HOME/vimrc.d ]]
    assertEquals 0 $?
    [[ -d $KYRAT_HOME/tmux.conf.d ]]
    assertEquals 0 $?
}

function test_execute_ssh_no_base64(){
    BASE64=not-existing-command
    assertCommandFailOnStatus 111 _execute_ssh
    assertEquals "kyrat requires not-existing-command to be installed locally. Aborting." "$(cat $STDERRF)"
}

function test_execute_ssh_no_gzip(){
    GZIP=not-existing-command
    assertCommandFailOnStatus 111 _execute_ssh
    assertEquals "kyrat requires not-existing-command to be installed locally. Aborting." "$(cat $STDERRF)"
}

function test_execute_ssh(){
    ssh_func(){
        echo "$@"
    }
    SSH=ssh_func
    SSH_OPTS=("-o" "bla")
    _get_remote_command(){
        echo "remote_command"
    }
    assertCommandSuccess _execute_ssh
    assertEquals "-t -o bla -- bash -c 'remote_command'" "$(cat $STDOUTF)"
}

function test_execute_ssh_no_opts(){
    ssh_func(){
        echo "$@"
    }
    SSH=ssh_func
    SSH_OPTS=()
    _get_remote_command(){
        echo "remote_command"
    }
    assertCommandSuccess _execute_ssh
    assertEquals "-t -- bash -c 'remote_command'" "$(cat $STDOUTF)"
}

function test_get_remote_command_no_command(){
    echo "bashrc" > $KYRAT_HOME/bashrc
    echo "zshrc" > $KYRAT_HOME/zshrc
    echo "inputrc" > $KYRAT_HOME/inputrc
    echo "vimrc" > $KYRAT_HOME/vimrc
    echo "tmux.conf" > $KYRAT_HOME/tmux.conf
    COMMANDS=()
    bash_func(){
        local kyrat_home=$(echo "$2" | sed 's/\/bashrc//')
        assertEquals "--rcfile $kyrat_home/bashrc -i" "$(echo "$@")"
        assertEquals "bashrc" "$(cat $kyrat_home/bashrc)"
        assertEquals "zshrc" "$(cat $kyrat_home/.zshrc)"
        assertEquals "inputrc" "$(cat $kyrat_home/inputrc)"
        assertEquals "vimrc" "$(cat $kyrat_home/vimrc)"
        assertEquals "tmux.conf" "$(cat $kyrat_home/tmux.conf)"
        assertEquals "$kyrat_home/inputrc" "$INPUTRC"
        assertEquals "let \$MYVIMRC=\"$kyrat_home/vimrc\" | source \$MYVIMRC" "$VIMINIT"
        assertEquals "$kyrat_home/tmux.conf" $TMUX_CONF
        assertEquals "$kyrat_home" $ZDOTDIR
        echo "$kyrat_home"
    }
    BASH=bash_func
    assertCommandSuccess _get_remote_command
    local remote_command="$STDOUTF"

    assertCommandSuccess eval "$(cat $remote_command)"
    cat $STDOUTF
    # Check that the kyrat home directory has been removed
    [[ -d "$(cat $STDOUTF)" ]]
    assertEquals 1 $?
}

function test_get_remote_command(){
    echo "bashrc" > $KYRAT_HOME/bashrc
    echo "inputrc" > $KYRAT_HOME/inputrc
    echo "vimrc" > $KYRAT_HOME/vimrc
    echo "zshrc" > $KYRAT_HOME/zshrc
    echo "tmux.conf" > $KYRAT_HOME/tmux.conf

    COMMANDS=("mycommand -la")
    bash_func(){
        local kyrat_home=$(echo "$2" | sed 's/\/bashrc//')
        assertEquals "--rcfile $kyrat_home/bashrc -i -c mycommand -la" "$(echo "$@")"
        assertEquals "bashrc" "$(cat $kyrat_home/bashrc)"
        assertEquals "zshrc" "$(cat $kyrat_home/.zshrc)"
        assertEquals "inputrc" "$(cat $kyrat_home/inputrc)"
        assertEquals "vimrc" "$(cat $kyrat_home/vimrc)"
        assertEquals "tmux.conf" "$(cat $kyrat_home/tmux.conf)"
        assertEquals "$kyrat_home/inputrc" "$INPUTRC"
        assertEquals "let \$MYVIMRC=\"$kyrat_home/vimrc\" | source \$MYVIMRC" "$VIMINIT"
        assertEquals "$kyrat_home/tmux.conf" $TMUX_CONF
        assertEquals "$kyrat_home" $ZDOTDIR
        echo "$kyrat_home"
    }
    BASH=bash_func
    KYRAT_SHELL=bash_func
    assertCommandSuccess _get_remote_command
    local remote_command="$STDOUTF"

    assertCommandSuccess eval "$(cat $remote_command)"
    # Check that the kyrat home directory has been removed
    [[ -d "$(cat $STDOUTF)" ]]
    assertEquals 1 $?
}

function test_get_remote_command_nested(){
    COMMANDS=("bash" "-c" "bash -c \"ls -l\"")

    bash_func(){
        assertEquals "--rcfile $kyrat_home/bashrc -i -c bash -c bash -c ls -l" "$(echo "$@")"
    }
    BASH=bash_func
    assertCommandSuccess _get_remote_command
    local remote_command="$STDOUTF"

    assertCommandSuccess eval "$(cat $remote_command)"
    # Check that the kyrat home directory has been removed
    [[ -d "$(cat $STDOUTF)" ]]
    assertEquals 1 $?
}

function test_get_remote_command_no_base64(){
    echo "bashrc" > $KYRAT_HOME/bashrc
    echo "inputrc" > $KYRAT_HOME/inputrc
    echo "vimrc" > $KYRAT_HOME/vimrc
    echo "vimrc" > $KYRAT_HOME/zshrc
    echo "tmux.conf" > $KYRAT_HOME/tmux.conf
    BASE64="not-exist"

    assertCommandSuccess _get_remote_command
    local remote_command="$STDOUTF"

    assertCommandFailOnStatus 111 eval "$(cat $remote_command)"
    assertEquals "kyrat requires not-exist command on the remote host. Aborting." "$(cat $STDERRF)"
}

function test_get_remote_command_no_gunzip(){
    echo "bashrc" > $KYRAT_HOME/bashrc
    echo "inputrc" > $KYRAT_HOME/inputrc
    echo "vimrc" > $KYRAT_HOME/vimrc
    echo "zshrc" > $KYRAT_HOME/zshrc
    echo "tmux.conf" > $KYRAT_HOME/tmux.conf
    GUNZIP="not-exist"

    assertCommandSuccess _get_remote_command
    local remote_command="$STDOUTF"

    assertCommandFailOnStatus 111 eval "$(cat $remote_command)"
    assertEquals "kyrat requires not-exist command on the remote host. Aborting." "$(cat $STDERRF)"
}

function test_get_remote_command_no_base_dirs(){
    echo "bashrc" > $KYRAT_HOME/bashrc
    echo "inputrc" > $KYRAT_HOME/inputrc
    echo "vimrc" > $KYRAT_HOME/vimrc
    echo "zshrc" > $KYRAT_HOME/zshrc
    echo "tmux.conf" > $KYRAT_HOME/tmux.conf
    BASE_DIRS=("/")

    assertCommandSuccess _get_remote_command
    local remote_command="$STDOUTF"

    assertCommandFailOnStatus 112 eval "$(cat $remote_command)"
    assertEquals "Could not find writable temp directory on the remote host. Aborting." "$(cat $STDERRF)"
}

source $(dirname $0)/../utils/shunit2
