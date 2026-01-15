# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

これは個人用dotfilesリポジトリで、macOSの開発環境を自動セットアップするための設定ファイルとスクリプトを管理しています。2026年現在の技術スタックで全面刷新されています。

## Setup and Installation

### Automated Setup
```bash
# One-liner setup (from GitHub) - Recommended
bash -c "$(curl -fsSL https://raw.githubusercontent.com/tokichie/dotfiles/main/bootstrap.sh)"

# Or clone and run locally
git clone https://github.com/tokichie/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./bootstrap.sh
```

### What bootstrap.sh Does
0. dotfilesリポジトリを`~/.dotfiles`にクローン（未存在時）
1. Homebrewをインストール（未インストール時）
2. Brewfileから依存関係をインストール
3. dotfilesのシンボリックリンクを作成（`_*` → `~/.*`、`config/*` → `~/.config/*`）
4. sheldonプラグインをインストール
5. miseでバージョン管理ツールをインストール（Node/Python/Ruby/Go）
6. Google Cloud SDKをインストール
7. zshをデフォルトシェルに設定
8. macOSシステム設定を構成（ディスプレイ、キーボード、トラックパッド、Dock、スクリーンショット）
9. キーボードリマッピング用LaunchAgentをインストール

**重要**:
- ワンライナーで実行する場合、git/Xcode Command Line Toolsが必要です
- デフォルトシェルの設定時にsudoパスワードを求められる場合があります
- スクリプト全体を`sudo`で実行する必要はありません（必要な箇所でのみsudoを使用）

### Post-Installation
```bash
# Verify installation
mise doctor
mise list
sheldon list

# Clean up old version managers (optional)
rm -rf ~/.rbenv ~/.goenv ~/.pyenv ~/.n
```

## Technology Stack

| Category | Tool | Description |
|----------|------|-------------|
| Version Manager | [mise](https://mise.jdx.dev/) | Rust製の統合バージョンマネージャー（rbenv/goenv/pyenv/nを統合） |
| Plugin Manager | [sheldon](https://sheldon.cli.rs/) | Rust製のzshプラグインマネージャー（zplugの代替） |
| VCS | [Jujutsu (jj)](https://github.com/martinvonz/jj) | 次世代VCS、Gitと互換性あり（主要なバージョン管理ツール） |
| Git TUI | [lazygit](https://github.com/jesseduffield/lazygit) | Go製のGit TUI（tigの代替） |
| Prompt | [pure](https://github.com/sindresorhus/pure) | ミニマルなzshプロンプト |
| Package Manager | [Homebrew](https://brew.sh/) | macOSパッケージマネージャー |

## File Structure

```
~/.dotfiles/
├── bootstrap.sh              # メインセットアップスクリプト
├── Brewfile                  # Homebrew依存関係定義
├── _zshrc                    # zsh設定（sheldon + mise統合）
├── _gitconfig                # Git設定
├── README.md                 # ドキュメント
├── CLAUDE.md                 # このファイル
├── LaunchAgents/
│   └── com.user.keyremapping.plist  # キーボードリマッピング設定
└── config/
    ├── sheldon/
    │   └── plugins.toml      # zshプラグイン定義
    ├── lazygit/
    │   └── config.yml        # lazygit設定
    └── mise/
        └── config.toml       # グローバルツールバージョン
```

## Configuration Files

### bootstrap.sh
- 冪等性: 複数回実行しても安全
- エラーハンドリング: `set -euo pipefail`で堅牢性確保。sudo失敗時も継続
- ログ機能: 色付きログで進捗を明示
- バックアップ機能: 既存ファイルを`.backup`として保存
- sudo管理: 必要な箇所でのみsudoを使用。失敗時は手動手順を案内

### Brewfile
`brew bundle`で使用される宣言的な依存関係定義。以下を含む:
- CLI ツール: zsh, git, gh, ghq, fzf, jq, yq, direnv, neovim, tmux, etc.
- 開発ツール: mise, sheldon, lazygit, jj, git-delta
- メディア: ffmpeg, imagemagick
- クラウド/インフラ: terraform, tflint, tenv, azure-cli, cloudflared, supabase, gcloud, kubectl, cue
- データベース: pgcli, libpq
- GUI アプリ: VS Code, Cursor, Ghostty, Raycast, Obsidian, Bitwarden, Google Japanese IME, etc.

### _zshrc
zshの設定ファイル。以下の機能を含む:

**プラグイン管理（sheldon）:**
- `eval "$(sheldon source)"` - sheldonでプラグインをロード
- syntax-highlighting, history-substring-search, autosuggestions, enhancd, pure

**バージョンマネージャー（mise）:**
- `eval "$(mise activate zsh)"` - miseを有効化
- Node/Python/Ruby/Goを一元管理

**プロンプトカスタマイズ:**
- プロジェクト内で言語バージョンを左プロンプトに表示
- `.mise.toml`や`go.mod`がある場合のみ表示

**カスタムヘルパー関数:**
- `git-checkout` / `c`: fzfを使ったブランチ切り替え
- `git-checkout-tag` / `ct`: fzfを使ったタグ切り替え
- `convert-to-gif` / `giffy`: 動画をGIFに変換

**エイリアス:**
- Git: `p`, `gl`, `glo`, `c`, `ct`, `cb`, `b`, `f`, `cm`, `pb`
- Git TUI: `lg` (lazygit)
- Jujutsu: `j`
- Editor: `vi` (nvim)

### config/sheldon/plugins.toml
sheldonのプラグイン定義。TOML形式で以下を管理:
```toml
[plugins.zsh-syntax-highlighting]
github = "zsh-users/zsh-syntax-highlighting"

[plugins.pure]
github = "sindresorhus/pure"
use = ["*.zsh"]
apply = ["fpath"]
```

### config/mise/config.toml
グローバルなツールバージョン設定:
```toml
[tools]
node = "lts"
python = "3.12"
ruby = "3.3"
go = "1.23"
```

プロジェクトごとのバージョン指定は`.mise.toml`で可能。

### config/lazygit/config.yml
lazygitの設定:
- カスタムコマンド: `C` (commit amend), `P` (push with upstream)
- git-deltaを使ったdiff表示
- Nerd Fontsアイコン対応

### _gitconfig
- ghqのルートディレクトリ: `~/ghq`
- カスタムエイリアス: `delete-merged-branches` (マージ済みブランチの削除)
- 自動prune: `fetch.prune = true`

### LaunchAgents/com.user.keyremapping.plist
システム起動時に自動実行されるキーボードリマッピング設定。`hidutil`を使用して以下のキーを入れ替え:
- **Caps Lock → Control**: Caps Lockキーを押すとControlキーとして動作
- **Left Control → Escape**: 左Controlキーを押すとEscapeキーとして動作

LaunchAgentは`~/Library/LaunchAgents/`にコピーされ、`launchctl`で自動ロードされます。

#### 手動でのキーリマッピング管理
```bash
# LaunchAgentをアンロード（無効化）
launchctl unload ~/Library/LaunchAgents/com.user.keyremapping.plist

# LaunchAgentをロード（有効化）
launchctl load ~/Library/LaunchAgents/com.user.keyremapping.plist

# 現在のキーマッピングを確認
hidutil property --get "UserKeyMapping"
```

## macOS System Settings

bootstrap.shは以下のmacOSシステム設定を自動構成します：

### Display
- 最大スケール解像度に設定（displayplacerを使用）

### Keyboard
- **キーリピート速度**: 最速（KeyRepeat = 1）
- **キーリピート開始遅延**: 短め（InitialKeyRepeat = 15）
- **ファンクションキー**: F1-F12を標準のファンクションキーとして動作（特殊機能はFnキー併用）
- **キーリマッピング**（LaunchAgent経由）:
  - Caps Lock → Control
  - Left Control → Escape

### Keyboard Shortcuts
- **Spotlight**: 無効化（Cmd+Space, Cmd+Option+Space）- Raycast使用のため
- **Mission Control - Desktop切り替え**: Ctrl+1〜5で5つのデスクトップを切り替え
- **Mission Control - その他**: 不要なショートカット（Show Notification Center, Application Windows等）を無効化

### Trackpad
- **スクロール方向**: ナチュラルスクロールを無効化（従来のスクロール方向）
- **トラッキング速度**: 3（システム環境設定の「速い」と「遅い」の中間より速め）
- **タップでクリック**: 有効（内蔵トラックパッド、Bluetoothトラックパッド、ログイン画面）

### Dock
- **タイルサイズ**: 45ピクセル

### Screenshots
- **保存先**: `~/Pictures/ScreenShots/`

## Common Tasks

### Update Dependencies
```bash
# Update Homebrew packages
brew update && brew upgrade

# Update sheldon plugins
sheldon lock --update

# Update mise tools
mise upgrade
```

### Add New Package
```bash
# Edit Brewfile
echo 'brew "package-name"' >> ~/.dotfiles/Brewfile

# Install
brew bundle --file=~/.dotfiles/Brewfile
```

### Change Tool Versions
```bash
# Edit mise config
vim ~/.config/mise/config.toml

# Install new version
mise install
```

## Version Control Workflow

**重要: このリポジトリはJujutsu (jj)で管理されています。**

Jujutsuは次世代のバージョン管理システムで、Gitと完全に互換性があります。このプロジェクトでは、すべてのコミットとプッシュ操作にjjを使用してください。

### 基本的なワークフロー

```bash
# 変更を確認
jj status

# コミット（変更の説明を設定）
jj describe -m "コミットメッセージ"

# mainブックマークを現在のコミットに移動
jj bookmark set main

# リモートにプッシュ
jj git push

# または一括実行
jj bookmark set main && jj git push
```

### jjの特徴

- **自動コミット**: 作業ディレクトリの変更は自動的に追跡される
- **ブックマーク**: Gitのブランチに相当（`main`ブックマークを使用）
- **変更IDベース**: コミットハッシュではなく変更IDで管理
- **Git互換**: `jj git push/pull`でGitリポジトリと同期

### Claude Codeへの指示

**dotfilesリポジトリでの作業時は、必ずjjを使用してください:**
1. ファイルを編集した後、`jj describe`でコミットメッセージを設定
2. `jj bookmark set main`でmainブックマークを更新
3. `jj git push`でリモートにプッシュ

**gitコマンドは使用しないでください。** すべてのバージョン管理操作はjjで行います。

## File Naming Convention

- `_filename` → `~/.filename`としてシンボリックリンクされる
- 例: `_zshrc` → `~/.zshrc`, `_gitconfig` → `~/.gitconfig`
- `config/dirname` → `~/.config/dirname`としてシンボリックリンクされる

## Important Notes

### cdコマンドの使用時
cdコマンドを使う場合は、事前に `source ~/.zshrc` を実行する必要があります（グローバル設定より）。

### 環境変数とPATH
_zshrcは以下の環境を設定します:
- Homebrew (`/opt/homebrew`)
- mise（バージョンマネージャー）
- pnpm
- Google Cloud SDK
- OpenJDK 21
- libpq (PostgreSQL)

### プロンプトのバージョン表示
- プロジェクトディレクトリ内（`.mise.toml`、`.node-version`、`go.mod`が存在）でのみ表示
- Node: 黄色の⬢アイコン
- Go: シアンの󰟓アイコン

## Troubleshooting

### sheldon plugins not loading
```bash
sheldon lock --update
source ~/.zshrc
```

### mise command not found
```bash
# Ensure mise is activated in _zshrc
grep "mise activate" ~/.zshrc

# If missing, add it
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
source ~/.zshrc
```

### Prompt colors not displaying
```bash
# Check Nerd Font installation
brew install --cask font-fira-code-nerd-font

# Set terminal font to "FiraCode Nerd Font"
```

## Legacy Information

### Removed Tools
以下のツールは2026年のアップデートで削除されました:
- **zplug** → sheldonに移行
- **rbenv/goenv/pyenv/n** → miseに統合
- **tig** → lazygitに移行

### Migration Notes
旧dotfilesからの移行時は、レガシーディレクトリを手動削除:
```bash
rm -rf ~/.rbenv ~/.goenv ~/.pyenv ~/.n
```
