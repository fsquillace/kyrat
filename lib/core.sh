#!/usr/bin/env bash

KYRAT_HOME=${KYRAT_HOME:-${HOME}/.config/kyrat}
KYRAT_TMPDIR=${KYRAT_TMPDIR:-/tmp}
KYRAT_SHELL=${KYRAT_SHELL:-bash}

BASE64=base64
BASH=${KYRAT_BASH:-bash}
ZSH=${KYRAT_ZSH:-zsh}
SH=${KYRAT_SH:-sh}
CAT=cat
GUNZIP=gunzip
GZIP=gzip
SSH=ssh
# PATH needs to be updated since GNU Coreutils is required in OSX environments
GNUBIN="/usr/local/opt/coreutils/libexec/gnubin"

NOT_EXISTING_COMMAND=111
NO_WRITABLE_DIRECTORY=112
KYRAT_SHELL_NOT_CORRECT=113

#######################################
# Concatenate files to standard output.
#
# Globals:
#   None
# Arguments:
#   files ($@)  :  the program arguments.
# Returns:
#   None
# Output:
#   The file contents.
#######################################
function _concatenate_files(){
    for file_rc in "$@"
    do
        if [[ -f "${file_rc}" ]]
        then
            cat "${file_rc}"
        elif [[ -e "${file_rc}" ]]
        then
            echo >&2 "Warn: ${file_rc} is not a file."
        fi
    done
}

#######################################
# Run ssh session with all config files
# in $KYRAT_HOME.
#
# Globals:
#   KYRAT_HOME (RO)  : Kyrat home location.
#   BASE64 (RO)      : base64 command.
#   GZIP (RO)        : gzip command.
#   GUNZIP (RO)      : gunzip command.
# Arguments:
#   args ($@)        : The ssh arguments.
# Returns:
#   None
# Output:
#   None
#######################################
function kyrat(){
    mkdir -p $KYRAT_HOME/bashrc.d
    mkdir -p $KYRAT_HOME/zshrc.d
    mkdir -p $KYRAT_HOME/inputrc.d
    mkdir -p $KYRAT_HOME/vimrc.d
    mkdir -p $KYRAT_HOME/tmux.conf.d
    _parse_args "$@"
    _execute_ssh
}

#######################################
# Parse the ssh arguments.
#
# Globals:
#   SSH (RO)         : ssh command.
#   SSH_OPTS (WO)    : The ssh options.
#   COMMANDS (WO)    : The ssh command to invoke remotely.
# Arguments:
#   args ($@)        : The ssh arguments.
# Returns:
#   None
# Output:
#   None
#######################################
function _parse_args(){
    [[ -z "$@" ]] && { $SSH; return $?; }

    SSH_OPTS=()
    for opt in "$@"; do
        case "$opt" in
            --) shift ; break ;;
            *) SSH_OPTS+=("$opt") ; shift ;;
        esac
    done

    COMMANDS=("$@")
}

#######################################
# Run ssh session with all config files
# in $KYRAT_HOME.
#
# Globals:
#   KYRAT_HOME (RO)      : Kyrat home location.
#   BASE64 (RO)          : base64 command.
#   GZIP (RO)            : gzip command.
#   GUNZIP (RO)          : gunzip command.
# Arguments:
#   args ($@)            : The ssh arguments.
# Returns:
#   NOT_EXISTING_COMMAND : if one of the required commands
#                          does not exist.
# Output:
#   None
#######################################
function _execute_ssh(){
    command -v $BASE64 >/dev/null 2>&1 || { echo >&2 "kyrat requires $BASE64 to be installed locally. Aborting."; return $NOT_EXISTING_COMMAND; }
    command -v $GZIP >/dev/null 2>&1 || { echo >&2 "kyrat requires $GZIP to be installed locally. Aborting."; return $NOT_EXISTING_COMMAND; }
    if [[ $KYRAT_SHELL != "$BASH" ]] && [[ $KYRAT_SHELL != "$ZSH" ]] && [[ $KYRAT_SHELL != "$SH" ]]
    then
        echo >&2 "KYRAT_SHELL not set correctly: $KYRAT_SHELL. Aborting."; return $KYRAT_SHELL_NOT_CORRECT;
    fi

    local remote_command="$(_get_remote_command)"
    $SSH -t "${SSH_OPTS[@]}" -- "$BASH -c '$remote_command'"
}

#######################################
# Compose and return the remote command
# to be executed inside the ssh session.
#
# Globals:
#   KYRAT_HOME (RO)       : Kyrat home location.
#   BASE64 (RO)           : base64 command.
#   GZIP (RO)             : gzip command.
#   GUNZIP (RO)           : gunzip command.
#   COMMANDS (RO?)        : ssh commands to execute (if any).
# Arguments:
#   None
# Returns:
#   NOT_EXISTING_COMMAND  : if one of the required commands
#                           does not exist.
#   NO_WRITABLE_DIRECTORY : if no writable directories could
#                           be found in the remote host.
# Output:
#   The composed remote command to execute in the ssh session.
#######################################
function _get_remote_command(){
    local bashrc_script="$(_concatenate_files "$KYRAT_HOME"/bashrc "$KYRAT_HOME"/bashrc.d/* | $GZIP | $BASE64)"
    local zshrc_script="$(_concatenate_files "$KYRAT_HOME"/zshrc "$KYRAT_HOME"/zshrc.d/* | $GZIP | $BASE64)"
    local inputrc_script="$(_concatenate_files "$KYRAT_HOME"/inputrc "$KYRAT_HOME"/inputrc.d/* | $GZIP | $BASE64)"
    local vimrc_script="$(_concatenate_files "$KYRAT_HOME"/vimrc "$KYRAT_HOME"/vimrc.d/* | $GZIP | $BASE64)"
    local tmux_conf="$(_concatenate_files "$KYRAT_HOME"/tmux.conf "$KYRAT_HOME"/tmux.conf.d/* | $GZIP | $BASE64)"

    if [[ $KYRAT_SHELL == "$BASH" ]]
    then
        KYRAT_SHELL_CMD="$BASH --rcfile "\${kyrat_home}/bashrc" -i"
    elif [[ $KYRAT_SHELL == "$ZSH" ]]
    then
        KYRAT_SHELL_CMD="$ZSH -i"
    elif [[ $KYRAT_SHELL == "$SH" ]]
    then
        KYRAT_SHELL_CMD="$SH -i"
    fi

    $CAT <<EOF
[[ -d "$GNUBIN" ]] && PATH="$GNUBIN:\$PATH";
[[ -w "$KYRAT_TMPDIR" ]] || { echo >&2 "Could not write into temp directory $KYRAT_TMPDIR on the remote host. Set KYRAT_TMPDIR env variable on a writable remote directory. Aborting."; exit $NO_WRITABLE_DIRECTORY; };
command -v $BASE64 >/dev/null 2>&1 || { echo >&2 "kyrat requires $BASE64 command on the remote host. Aborting."; exit $NOT_EXISTING_COMMAND; };
command -v $GUNZIP >/dev/null 2>&1 || { echo >&2 "kyrat requires $GUNZIP command on the remote host. Aborting."; exit $NOT_EXISTING_COMMAND; };
kyrat_home="\$(mktemp -d "$KYRAT_TMPDIR/kyrat-XXXXX")";
trap "rm -rf "\$kyrat_home"; exit" EXIT HUP INT QUIT PIPE TERM KILL;
EOF

    local commands_opt=""
    if [[ -n "${COMMANDS[@]}" ]]
    then
        commands_opt="-c \"${COMMANDS[@]}\""
    else
        $CAT <<EOF
[[ -e /etc/motd ]] && $CAT /etc/motd || { [[ -e /etc/update-motd.d ]] && command -v run-parts &> /dev/null && run-parts /etc/update-motd.d/; }
EOF
    fi

    $CAT <<EOF
echo "${bashrc_script}" | $BASE64 -di - | $GUNZIP >> "\${kyrat_home}/bashrc";
echo "${zshrc_script}" | $BASE64 -di - | $GUNZIP >> "\${kyrat_home}/.zshrc";
echo "${inputrc_script}" | $BASE64 -di - | $GUNZIP > "\${kyrat_home}/inputrc";
echo "${vimrc_script}" | $BASE64 -di - | $GUNZIP > "\${kyrat_home}/vimrc";
echo "${tmux_conf}" | $BASE64 -di - | $GUNZIP > "\${kyrat_home}/tmux.conf";
VIMINIT="let \\\$MYVIMRC=\\"\${kyrat_home}/vimrc\\" | source \\\$MYVIMRC" INPUTRC="\${kyrat_home}/inputrc" TMUX_CONF="\${kyrat_home}/tmux.conf" KYRAT_HOME="\${kyrat_home}" ZDOTDIR="\${kyrat_home}" ${KYRAT_SHELL_CMD} ${commands_opt};
EOF
}
