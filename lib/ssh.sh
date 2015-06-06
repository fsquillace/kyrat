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
    [ -z $PEARL_HOME ] && PEARL_HOME=${HOME}/.config/pearl

    local rcScript=""
    [ -f "$PEARL_HOME/sshrc" ] && rcScript=$(cat "$PEARL_HOME/sshrc")
    if [ -d "$PEARL_HOME/sshrc.d" ]; then
        rcScript="${rcScript}
    $(cat $PEARL_HOME/sshrc.d/* 2> /dev/null)"
    fi

    local inputrcScript=""
    [ -f "$PEARL_HOME/sshinputrc" ] && inputrcScript=$(cat "$PEARL_HOME/sshinputrc")

    rcScript=$(echo "$rcScript" | gzip | base64)
    inputrcScript=$(echo "$inputrcScript" | gzip | base64)

    CMD="PEARL_INSTALL=\$(mktemp -d pearl-XXXXX -p /tmp); echo \"${inputrcScript}\" | base64 -di | gunzip > \${PEARL_INSTALL}/inputrc; echo \"${rcScript}\" | base64 -di | gunzip > \${PEARL_INSTALL}/minipearl.sh; INPUTRC=\${PEARL_INSTALL}/inputrc bash --rcfile \${PEARL_INSTALL}/minipearl.sh -i; [ -d \${PEARL_INSTALL} ] && rm -rf \${PEARL_INSTALL}"

    ssh -t $@ -- "$CMD"
}

