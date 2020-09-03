#!/bin/bash

set -ex

DEFAULT_SHELL=${1:-/bin/bash}

sudo chsh -s $DEFAULT_SHELL $USER

mkdir -p ~/.config/kyrat
echo "alias q='exit'" > ~/.config/kyrat/bashrc
echo "alias q='exit'" > ~/.config/kyrat/zshrc

KYRAT_SHELL=sh ./bin/kyrat -o "StrictHostKeyChecking no" localhost -- echo \$SHELL

for shell in "bash" "zsh"
do
    export KYRAT_SHELL=$shell
    echo "Accessing to kyrat $shell session"

    ./bin/kyrat -o "StrictHostKeyChecking no" localhost -- echo \$SHELL
    ./bin/kyrat -o "StrictHostKeyChecking no" localhost -- ls -lh
    ./bin/kyrat -o "StrictHostKeyChecking no" localhost -- q
    ./bin/kyrat -o "StrictHostKeyChecking no" localhost -- [[ ! -z "\\\$INPUTRC" ]]
    ./bin/kyrat -o "StrictHostKeyChecking no" localhost -- [[ ! -z "\\\$VIMINIT" ]]
    ./bin/kyrat -o "StrictHostKeyChecking no" localhost -- [[ ! -z "\\\$TMUX_CONF" ]]
    ./bin/kyrat -o "StrictHostKeyChecking no" localhost -- [[ ! -z "\\\$ZDOTDIR" ]]

    echo -e "let myvariable=10\nlet myvariable\nq" > ~/.config/kyrat/vimrc
    VIM_OUTPUT="$(./bin/kyrat -o "StrictHostKeyChecking no" localhost -- vim)"

    echo "$VIM_OUTPUT" | grep myvariable || { echo "vimrc has not been loaded properly"; exit 1; }
done
