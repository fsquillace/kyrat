#!/usr/bin/env bash

KYRAT_HOME=${KYRAT_HOME:-${HOME}/.config/kyrat}

BASE64=base64
BASH=bash
CAT=cat
GUNZIP=gunzip
GZIP=gzip
SSH=ssh
# PATH needs to be updated since GNU Coreutils is required in OSX environments
GNUBIN="/usr/local/opt/coreutils/libexec/gnubin"

BASE_DIRS=("/tmp" "\$HOME")

NOT_EXISTING_COMMAND=111
NO_WRITABLE_DIRECTORY=112

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
    local rc_script="$(_concatenate_files "$KYRAT_HOME"/bashrc "$KYRAT_HOME"/bashrc.d/* | $GZIP | $BASE64)"
    local inputrc_script="$(_concatenate_files "$KYRAT_HOME"/inputrc "$KYRAT_HOME"/inputrc.d/* | $GZIP | $BASE64)"
    local vimrc_script="$(_concatenate_files "$KYRAT_HOME"/vimrc "$KYRAT_HOME"/vimrc.d/* | $GZIP | $BASE64)"
    local tmux_conf="$(_concatenate_files "$KYRAT_HOME"/tmux.conf "$KYRAT_HOME"/tmux.conf.d/* | $GZIP | $BASE64)"

    local commands_opt=""
    [[ -z "${COMMANDS[@]}" ]] || commands_opt="-c \"${COMMANDS[@]}\""
    $CAT <<EOF
[[ -e /etc/motd ]] && $CAT /etc/motd || { [[ -e /etc/update-motd.d ]] && command -v run-parts &> /dev/null && run-parts /etc/update-motd.d/; }
[[ -d "$GNUBIN" ]] && PATH="$GNUBIN:\$PATH";
for tmp_dir in ${BASE_DIRS[@]}; do [[ -w "\$tmp_dir" ]] && { base_dir="\$tmp_dir"; break; } done;
[[ -z "\$base_dir" ]] && { echo >&2 "Could not find writable temp directory on the remote host. Aborting."; exit $NO_WRITABLE_DIRECTORY; };
command -v $BASE64 >/dev/null 2>&1 || { echo >&2 "kyrat requires $BASE64 command on the remote host. Aborting."; exit $NOT_EXISTING_COMMAND; };
command -v $GUNZIP >/dev/null 2>&1 || { echo >&2 "kyrat requires $GUNZIP command on the remote host. Aborting."; exit $NOT_EXISTING_COMMAND; };
kyrat_home="\$(mktemp -d kyrat-XXXXX -p "\$base_dir")";
trap "rm -rf "\$kyrat_home"; exit" EXIT HUP INT QUIT PIPE TERM KILL;
[[ -e \${HOME}/.bashrc ]] && echo "source \${HOME}/.bashrc" > "\${kyrat_home}/bashrc";
echo "${rc_script}" | $BASE64 -di | $GUNZIP >> "\${kyrat_home}/bashrc";
echo "${inputrc_script}" | $BASE64 -di | $GUNZIP > "\${kyrat_home}/inputrc";
echo "${vimrc_script}" | $BASE64 -di | $GUNZIP > "\${kyrat_home}/vimrc";
echo "${tmux_conf}" | $BASE64 -di | $GUNZIP > "\${kyrat_home}/tmux.conf";
VIMINIT="let \\\$MYVIMRC=\\"\${kyrat_home}/vimrc\\" | source \\\$MYVIMRC" INPUTRC="\${kyrat_home}/inputrc" TMUX_CONF="\${kyrat_home}/tmux.conf" $BASH --rcfile "\${kyrat_home}/bashrc" -i ${commands_opt};
EOF
}
