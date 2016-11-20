#!/bin/bash

set -e

mkdir -p ~/.config/kyrat
echo "alias q='exit'" > ~/.config/kyrat/bashrc

./bin/kyrat -v -o "StrictHostKeyChecking no" localhost -- q
./bin/kyrat -v -o "StrictHostKeyChecking no" localhost -- ls -lh
./bin/kyrat -v -o "StrictHostKeyChecking no" localhost -- "[[ ! -z "\$INPUTRC" ]]"
./bin/kyrat -v -o "StrictHostKeyChecking no" localhost -- "[[ ! -z "\$VIMINIT" ]]"
