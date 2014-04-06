

# Open a ssh session and transfer a minimal
# version of pearl
function ssh_mini_pearl(){
[ -z $PEARL_HOME ] && PEARL_HOME=${HOME}/.config/pearl
local homeScript=""
[ -f $PEARL_HOME/pearlsshrc ] && homeScript=$(cat $PEARL_HOME/pearlsshrc)

local promptScript="export PS1='\[\033[31m\][\[\033[36m\]\h \[\033[34m\]\W \[\033[35m\]\$\[\033[31m\]]>\[\033[0m\] '"

local fromPearlScript=""
local inputrcScript=""
if [ -d "$PEARL_ROOT" ];
then
    local aliasesScript="$(cat $PEARL_ROOT/lib/aliases.sh)"
    local bindingsScript="$(cat $PEARL_ROOT/lib/bindings.sh)"
    local opsScript="$(cat $PEARL_ROOT/lib/ops.sh)"
    local optionsScript="$(cat $PEARL_ROOT/lib/options.sh)"
    local historyScript="$(cat $PEARL_ROOT/lib/history.sh)"
    fromPearlScript="${aliasesScript}
${bindingsScript}
${optionsScript}
${opsScript}
${historyScript}"

    inputrcScript="$(cat $PEARL_ROOT/etc/inputrc)"
fi

local commandScript="${fromPearlScript}
${promptScript}
${homeScript}"

commandScript=$(echo "$commandScript" | gzip | base64)
inputrcScript=$(echo "$inputrcScript" | gzip | base64)

CMD="PEARL_INSTALL=\$(mktemp -d pearl-XXXXX -p /tmp); echo \"${inputrcScript}\" | base64 -di | gunzip > \${PEARL_INSTALL}/inputrc; echo \"${commandScript}\" | base64 -di | gunzip > \${PEARL_INSTALL}/minipearl.sh; INPUTRC=\${PEARL_INSTALL}/inputrc bash --rcfile \${PEARL_INSTALL}/minipearl.sh -i; [ -d \${PEARL_INSTALL} ] && rm -rf \${PEARL_INSTALL}"

ssh -2 -t $@ -- "$CMD"
}


# Open a ssh session and create a complete pearl
# from either git or wget
function ssh_pearl(){
local installScript=""
if [ -d "$PEARL_ROOT" ];
then
    installScript=$(cat ${PEARL_ROOT}/lib/make.sh)
else
    installScript=$(wget -q -O - https://raw.github.com/fsquillace/pearl/master/lib/make.sh)
fi

local commandScript=$(echo "$installScript" | gzip | base64)

CMD="PEARL_INSTALL=\$(mktemp -d pearl-XXXXX -p /tmp); echo \"${commandScript}\" | base64 -di | gunzip > \${PEARL_INSTALL}/make.sh; bash \${PEARL_INSTALL}/make.sh; bash --rcfile \$HOME/.pearl/pearl -i; [ -d \${PEARL_INSTALL} ] && rm -rf \${PEARL_INSTALL}"

ssh -2 -t $@ -- "$CMD"
}

