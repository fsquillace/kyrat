#!/usr/bin/env bash

function kyrat(){
    function _aggregate_scripts(){
        local fileRc="$1"
        local dirRc="$2"
        [[ -f "${fileRc}" ]] && cat "${fileRc}"
        [[ -d "${dirRc}" ]] && [[ "$(ls -A ${dirRc})" ]] && cat "${dirRc}"/*
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

    command -v base64 >/dev/null 2>&1 || { echo >&2 "kyrat requires base64 to be installed locally. Aborting."; return 1; }
    command -v gzip >/dev/null 2>&1 || { echo >&2 "kyrat requires gzip to be installed locally. Aborting."; return 1; }

    [[ -z "$KYRAT_HOME" ]] && KYRAT_HOME=${HOME}/.config/kyrat

    local rcScript="$(_aggregate_scripts "$KYRAT_HOME/bashrc" "$KYRAT_HOME/bashrc.d" | gzip | base64)"
    local inputrcScript="$(_aggregate_scripts "$KYRAT_HOME/inputrc" "$KYRAT_HOME/inputrc.d" | gzip | base64)"
    local vimrcScript="$(_aggregate_scripts "$KYRAT_HOME/vimrc" "$KYRAT_HOME/vimrc.d" | gzip | base64)"

    CMD="
        for tmpDir in /tmp \$HOME; do [[ -w \"\$tmpDir\" ]] && { foundTmpDir=\"\$tmpDir\"; break; } done;
        [[ -z \"\$foundTmpDir\" ]] && { echo >&2 \"Could not find writable tempdirs on the server. Aborting.\"; exit 1; };
        command -v base64 >/dev/null 2>&1 || { echo >&2 \"kyrat requires base64 to be installed on the server. Aborting.\"; exit 1; };
        command -v gunzip >/dev/null 2>&1 || { echo >&2 \"kyrat requires gunzip to be installed on the server. Aborting.\"; exit 1; };
        KYRAT_HOME=\"\$(mktemp -d kyrat-XXXXX -p \"\$foundTmpDir\")\";
        trap \"rm -rf \"\$KYRAT_HOME\"; exit\" EXIT HUP INT QUIT PIPE TERM KILL;
        echo \"${rcScript}\" | base64 -di | gunzip > \"\${KYRAT_HOME}/bashrc\";
        echo \"${inputrcScript}\" | base64 -di | gunzip > \"\${KYRAT_HOME}/inputrc\";
        echo \"${vimrcScript}\" | base64 -di | gunzip > \"\${KYRAT_HOME}/vimrc\";
        VIMINIT=\"let \\\$MYVIMRC='\${KYRAT_HOME}/vimrc' | source \\\$MYVIMRC\" INPUTRC=\"\${KYRAT_HOME}/inputrc\" bash --rcfile \"\${KYRAT_HOME}/bashrc\" -i ${commands_opt};
    "

    ssh -t "${ssh_opts[@]}" -- "$CMD"
}
