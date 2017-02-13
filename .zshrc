ZPLUG_HOME=/usr/local/opt/zplug
source $ZPLUG_HOME/init.zsh

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# 「ユーザ名/リポジトリ名」で記述し、ダブルクォートで見やすく括る（括らなくてもいい）
zplug "zsh-users/zsh-syntax-highlighting"
zplug "zsh-users/zsh-history-substring-search"

# junegunn/dotfiles にある bin の中の vimcat をコマンドとして管理する
zplug "junegunn/dotfiles", as:command, use:bin/vimcat

# tcnksm/docker-alias にある zshrc をプラグインとして管理する
# as: のデフォルトは plugin なので省力もできる
zplug "tcnksm/docker-alias", use:zshrc, as:plugin

# frozen: を指定すると全体アップデートのときアップデートしなくなる（デフォルトは0）
zplug "k4rthik/git-cal", as:command, frozen:1

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

# from: では gist を指定することができる
# gist のときもリポジトリと同様にタグを使うことができる
zplug "b4b4r07/79ee61f7c140c63d2786", \
    from:gist, \
    as:command, \
    use:get_last_pane_path.sh

# パイプで依存関係を表現できる
# 依存関係はパイプの流れのまま
# この例では emoji-cli は jq に依存する
zplug "stedolan/jq", \
    as:command, \
    rename-to:jq, \
    from:gh-r

# zplug "mafredri/zsh-async", on:sindresorhus/pure
# zplug "sindresorhus/pure", use:pure.zsh

zplug "zsh-users/zsh-autosuggestions", use:zsh-autosuggestions.zsh

# check コマンドで未インストール項目があるかどうか verbose にチェックし
# false のとき（つまり未インストール項目がある）y/N プロンプトで
# インストールする
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# プラグインを読み込み、コマンドにパスを通す
zplug load --verbose

alias t='tig'
alias st='tig status'
alias p='git pull origin'
alias gl='git log --decorate'
alias glo='git log --oneline'
alias c='git checkout'
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

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

export NVM_DIR="/Users/yuta.tokitake/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

clear
