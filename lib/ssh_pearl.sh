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

function ssh_pearl(){
    function _aggregate_scripts(){
        local fileRc="$1"
        local dirRc="$2"
        [[ -f "${fileRc}" ]] && cat "${fileRc}"
        [[ -d "${dirRc}" ]] && cat "${dirRc}"/*
    }
    [[ -z "$@" ]] && { ssh; return $?; }

    local ssh_opts=()
    for opt in "$@"; do
        case "$opt" in
            --) shift ; break ;;
            *) ssh_opts+=("$opt") ; shift ;;
        esac
    done

    local commands=()
    for arg in "$@"; do commands+=("$arg"); done
    local commands_opt=""
    [[ -z "${commands[@]}" ]] || commands_opt="-c '${commands[@]}'"

    command -v base64 >/dev/null 2>&1 || { echo >&2 "pearl-ssh requires base64 to be installed locally. Aborting."; return 1; }
    command -v gzip >/dev/null 2>&1 || { echo >&2 "pearl-ssh requires gzip to be installed locally. Aborting."; return 1; }

    [[ -z "$PEARL_HOME" ]] && PEARL_HOME=${HOME}/.config/pearl

    local rcScript="$(_aggregate_scripts "$PEARL_HOME/sshrc" "$PEARL_HOME/sshrc.d" | gzip | base64)"
    local inputrcScript="$(_aggregate_scripts "$PEARL_HOME/sshinputrc" "$PEARL_HOME/sshinputrc.d" | gzip | base64)"
    local vimrcScript="$(_aggregate_scripts "$PEARL_HOME/sshvimrc" "$PEARL_HOME/sshvimrc.d" | gzip | base64)"

    CMD="
        for tmpDir in /tmp \$HOME; do [[ -w \"\$tmpDir\" ]] && { foundTmpDir=\"\$tmpDir\"; break; } done;
        [[ -z \"\$foundTmpDir\" ]] && { echo >&2 \"Could not find writable tempdirs on the server. Aborting.\"; exit 1; };
        command -v base64 >/dev/null 2>&1 || { echo >&2 \"pearl-ssh requires base64 to be installed on the server. Aborting.\"; exit 1; };
        command -v gunzip >/dev/null 2>&1 || { echo >&2 \"pearl-ssh requires gunzip to be installed on the server. Aborting.\"; exit 1; };
        PEARLSSH_HOME=\"\$(mktemp -d pearl-XXXXX -p \"\$foundTmpDir\")\";
        trap \"rm -rf \"\$PEARLSSH_HOME\"; exit\" EXIT HUP INT QUIT PIPE TERM KILL;
        echo \"${rcScript}\" | base64 -di | gunzip > \"\${PEARLSSH_HOME}/bashrc\";
        echo \"${inputrcScript}\" | base64 -di | gunzip > \"\${PEARLSSH_HOME}/inputrc\";
        echo \"${vimrcScript}\" | base64 -di | gunzip > \"\${PEARLSSH_HOME}/vimrc\";
        VIMINIT=\"let \\\$MYVIMRC='\${PEARLSSH_HOME}/vimrc' | source \\\$MYVIMRC\" INPUTRC=\"\${PEARLSSH_HOME}/inputrc\" bash --rcfile \"\${PEARLSSH_HOME}/bashrc\" -i ${commands_opt};
    "

    ssh -t "${ssh_opts[@]}" -- "$CMD"
}
