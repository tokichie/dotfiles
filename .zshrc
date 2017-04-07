ZPLUG_HOME=/usr/local/opt/zplug
source $ZPLUG_HOME/init.zsh

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

bindkey -e
export GOPATH=$HOME/.go

# zsh plugins
zplug "zsh-users/zsh-syntax-highlighting"
zplug "zsh-users/zsh-history-substring-search"

# junegunn/dotfiles にある bin の中の vimcat をコマンドとして管理する
zplug "junegunn/dotfiles", as:command, use:bin/vimcat

# tcnksm/docker-alias にある zshrc をプラグインとして管理する
# as: のデフォルトは plugin なので省力もできる
zplug "tcnksm/docker-alias", use:zshrc, as:plugin

# from: で特殊ケースを扱える
# gh-r を指定すると GitHub Releases から取ってくる
# use: で amd64 とかするとそれを持ってくる（指定しないかぎりOSにあったものを自動で選ぶ）
# コマンド化するときに rename-to: でリネームできる（この例では fzf-bin を fzf にしてる）
zplug "junegunn/fzf-bin", \
    as:command, \
    from:gh-r, \
    rename-to:fzf

# from: では gh-r の他に oh-my-zsh と gist が使える
# oh-my-zsh を指定すると oh-my-zsh のリポジトリにある plugin/ 以下を
# コマンド／プラグインとして管理することができる
zplug "plugins/git", from:oh-my-zsh

# ビルド用 hook になっていて、この例ではクローン成功時に make install する
# シェルコマンドなら何でも受け付けるので "echo OK" などでも可
zplug "tj/n", hook-build:"make install"

# ブランチロック・リビジョンロック
# at: はブランチとタグをサポートしている
zplug "b4b4r07/enhancd", use:init.sh
zplug "mollifier/anyframe", at:4c23cb60

# zplug "mafredri/zsh-async", on:sindresorhus/pure
# zplug "sindresorhus/pure", use:pure.zsh

zplug "zsh-users/zsh-autosuggestions", use:zsh-autosuggestions.zsh

# zsh-history
# export ZSH_HISTORY_FILE="$HOME/.zsh/zsh_history.db"
# export ZSH_HISTORY_BACKUP_DIR="$HOME/.zsh/history/backup"
# export ZSH_HISTORY_FILTER="fzf"
# export ZSH_HISTORY_KEYBIND_GET_BY_DIR="^r"
# export ZSH_HISTORY_KEYBIND_GET_ALL="^r^a"
# export ZSH_HISTORY_KEYBIND_SCREEN="^r^r"
# export ZSH_HISTORY_KEYBIND_ARROW_UP="^p"
# export ZSH_HISTORY_KEYBIND_ARROW_DOWN="^n"
# source $HOME/lib/zsh-history/init.zsh

# check コマンドで未インストール項目があるかどうか verbose にチェックし
# false のとき（つまり未インストール項目がある）y/N プロンプトで
# インストールする
# if ! zplug check --verbose; then
#     printf "Install? [y/N]: "
#     if read -q; then
#         echo; zplug install
#     fi
# fi

# HISTORY
export HISTFILE=${HOME}/.zsh_history
export HISTSIZE=10000
export SAVEHIST=1000000
setopt hist_ignore_dups
setopt EXTENDED_HISTORY

function fzf-history-selection() {
  BUFFER=`history -n 1 | tail -r | awk '!a[$0]++' | fzf`
  CURSOR=$#BUFFER
  zle reset-prompt
}

zle -N fzf-history-selection
bindkey '^R' fzf-history-selection

# プラグインを読み込み、コマンドにパスを通す
zplug load --verbose

#
# History
#
export HISTFILE=${HOME}/.zsh_history
export HISTSIZE=1000
export SAVEHIST=1000000
setopt hist_ignore_dups
setopt EXTENDED_HISTORY

#
# Functions
#
function git-checkout-local() {
  if [ -n "$1" ]; then
    git checkout "$1"
  else
    local branches branch
    branches=$(git branch -vv) &&
    branch=$(echo "$branches" | fzf +m) &&
    git checkout $(echo "$branch" | awk '$0=$1' | sed "s/.* //")
  fi
}

#
# Aliases
#
alias t='tig'
alias st='tig status'
alias p='git pull origin'
alias gl='git log --decorate'
alias glo='git log --oneline'
alias c='git-checkout-local'
alias cb='git checkout -b'
alias b='git branch'
alias f='git fetch --prune'
alias cm='git commit'
function git_current_branch_name()
{
  git branch | grep '^\*' | sed 's/^\* *//'
}
alias -g B='"$(git_current_branch_name)"'

alias pushB='git push origin B'

alias vi='vim'

export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$ANDROID_HOME/platform-tools:$PATH"

eval "$(rbenv init -)"

export NVM_DIR="$HOME/.nvm"
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    . "$NVM_DIR/nvm.sh"
elif [[ -s /usr/local/opt/nvm/nvm.sh ]]; then
    . "/usr/local/opt/nvm/nvm.sh"
fi

ssh-add > /dev/null

clear

if (which zprof > /dev/null 2>&1); then
    zprof
fi

