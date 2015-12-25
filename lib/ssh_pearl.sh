#!/usr/bin/env bash
#
# This file is part of Pearl (https://github.com/fsquillace/pearl-ssh).
#
# Copyright (c) 2008-2015
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU Library General Public License as published
# by the Free Software Foundation; either version 2, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#


function ssh_pearl() {
    local self lib rcScript inputrcScript vimrcScript ssh_opts opt commands arg commands_opt is_script

    commands=()
    ssh_opts=()

    function _aggregate_scripts() {
        local node

        echo -e '\n'  # to enforce there's linefeed after previous block
        for node in "$@"; do
            [[ -f "$node" ]] && cat "$node"
            [[ -d "$node" ]] && cat "$node"/*
        done
    }

    [[ "$1" == __SCRIPT_INVOCATION__ ]] && is_script=1 && shift
    [[ -z "$@" ]] && { ssh; return $?; }

    for opt in "$@"; do
        case "$opt" in
            --) shift ; break ;;
            *)  ssh_opts+=("$opt") ; shift ;;
        esac
    done

    for arg in "$@"; do
        commands+=("$arg")
    done

    [[ -n "${commands[@]}" ]] && commands_opt="-c '${commands[*]}'"

    command -v base64 >/dev/null 2>&1 || { echo >&2 "pearl-ssh requires base64 to be installed locally. Aborting."; return 1; }
    command -v gzip >/dev/null 2>&1 || { echo >&2 "pearl-ssh requires gzip to be installed locally. Aborting."; return 1; }

    [[ -z "$PEARL_HOME" ]] && PEARL_HOME=${HOME}/.config/pearl

    [[ "$is_script" -ne 1 && "$__REMOTE_SSH" -ne 1 ]] && rcScript="$(declare -f "$FUNCNAME")"
    rcScript+="$(_aggregate_scripts "$PEARL_HOME/bashrc" "$PEARL_HOME/bashrc.d")"
    rcScript="$(echo "$rcScript" | gzip | base64)"
    inputrcScript="$(_aggregate_scripts "$PEARL_HOME/inputrc" "$PEARL_HOME/inputrc.d" | gzip | base64)"
    vimrcScript="$(_aggregate_scripts "$PEARL_HOME/vimrc" "$PEARL_HOME/vimrc.d" | gzip | base64)"
    if [[ "$is_script" -eq 1 ]]; then
        self="$(gzip < "$0" | base64)"
        lib="$(gzip < "$(resolve_real_path "$0")/../lib/$LIBNAME" | base64)"
    fi

    CMD="
        export __REMOTE_SSH=1  # states we're over ssh session
        for tmpDir in /tmp \$HOME; do [[ -w \"\$tmpDir\" ]] && { foundTmpDir=\"\$tmpDir\"; break; } done
        [[ -z \"\$foundTmpDir\" ]] && { echo >&2 \"couldn't find writable tempdirs on the server. Aborting.\"; exit 1; };
        command -v base64 >/dev/null 2>&1 || { echo >&2 \"pearl-ssh requires base64 to be installed on the server. Aborting.\"; exit 1; };
        command -v gunzip >/dev/null 2>&1 || { echo >&2 \"pearl-ssh requires gunzip to be installed on the server. Aborting.\"; exit 1; };
        PEARLSSH_ROOT=\"\$(mktemp -d pearl-XXXXX -p \"\$foundTmpDir\")\" || exit 1
        PEARLSSH_ETC=\"\$PEARLSSH_ROOT/etc\"
        mkdir \"\$PEARLSSH_ETC\" || exit 1
        PEARLSSH_BIN=\"\$PEARLSSH_ROOT/bin\"
        mkdir \"\$PEARLSSH_BIN\" || exit 1
        PEARLSSH_LIB=\"\$PEARLSSH_ROOT/lib\"
        mkdir \"\$PEARLSSH_LIB\" || exit 1
        export PEARL_HOME=\"\$PEARLSSH_ETC\";
        trap \"rm -rf \"\$PEARLSSH_ROOT\"; exit\" EXIT HUP INT QUIT PIPE TERM;
        echo \"${rcScript}\" | base64 -di | gunzip > \"\${PEARLSSH_ETC}/bashrc\";
        echo \"${inputrcScript}\" | base64 -di | gunzip > \"\${PEARLSSH_ETC}/inputrc\";
        echo \"${vimrcScript}\" | base64 -di | gunzip > \"\${PEARLSSH_ETC}/vimrc\";
        if [[ \"$is_script\" -eq 1 ]]; then
            echo \"${self}\" | base64 -di | gunzip > \"\${PEARLSSH_BIN}/$SELF\";
            echo \"${lib}\" | base64 -di | gunzip > \"\${PEARLSSH_LIB}/$LIBNAME\";
        fi
        chmod -R +x \"\$PEARLSSH_BIN\";
        export PATH=\$PATH:\$PEARLSSH_BIN;
        VIMINIT=\"let \\\$MYVIMRC='\${PEARLSSH_ETC}/vimrc' | source \\\$MYVIMRC\" INPUTRC=\"\${PEARLSSH_ETC}/inputrc\" bash --rcfile \"\${PEARLSSH_ETC}/bashrc\" -i ${commands_opt};
    "

    ssh -t "${ssh_opts[@]}" -- "$CMD"
}

