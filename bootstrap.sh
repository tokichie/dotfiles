#!/bin/bash
set -e
set -u
set -x

###
##  common functions
###
cmd_missing() {
    !(type "$1" > /dev/null 2>&1)
}

###
##  1. install homebrew
###
if cmd_missing "brew"; then
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" 
fi

###
##  2. install essentials via homebrew
###
declare -a ESSENTIALS=(
    "zsh"
    "tig"
    "ghq"
    "jq"
    "fzf"
    "n"
    "rbenv"
    "goenv"
    "zplug"
)
for cmd in "${ESSENTIALS[@]}"; do
    if cmd_missing $cmd; then brew install $cmd; fi
done

###
##  3. setup zplug
###
zplug install

$ZPLUG_HOME=/usr/local/opt/zplug

mkdir -p $HOME/.zfunctions
ln -s $ZPLUG_HOME/repos/sindresorhus/pure/async.zsh $HOME/.zfunctions/async
ln -s $ZPLUG_HOME/repos/sindresorhus/pure/pure.zsh $HOME/.zfunctions/prompt_pure_setup
