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

realpath () {
    f=$@;
    if [ -d "$f" ]; then
        base="";
        dir="$f";
    else
        base="/$(basename "$f")";
        dir=$(dirname "$f");
    fi;
    dir=$(cd "$dir" && /bin/pwd);
    echo "$dir$base"
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
    "direnv"
    "nvim"
    "yarn"
)
for cmd in "${ESSENTIALS[@]}"; do
    if cmd_missing $cmd; then brew install $cmd; fi
done

###
##  3. setup zplug
###
ZPLUG_HOME=/usr/local/opt/zplug
if [ ! -d $ZPLUG_HOME]; then
    brew install zplug
fi

mkdir -p $HOME/.zfunctions
if [ ! -f $HOME/.zfunctions/async ]; then
    ln -s $ZPLUG_HOME/repos/sindresorhus/pure/async.zsh $HOME/.zfunctions/async
fi
if [ ! -f $HOME/.zfunctions/prompt_pure_setup ]; then
    ln -s $ZPLUG_HOME/repos/sindresorhus/pure/pure.zsh $HOME/.zfunctions/prompt_pure_setup
fi

###
##  4. create symlinks
###
DOTFILES_DIR=$(dirname $0)
for FILE in $(ls $DOTFILES_DIR/_*); do
    FULLPATH=$(realpath $FILE)
    DOTFILE=$(echo $FILE | sed -E 's/.*\/_(.+)$/.\1/')
    if [ ! -f $HOME/$DOTFILE ]; then
        ln -s $FULLPATH $HOME/$DOTFILE
    fi
done

