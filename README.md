# dotfiles

Modern dotfiles configuration for macOS development environment.

## Features

- **One-line setup**: Fully automated installation with a single command
- **Modern stack**: mise (version manager), sheldon (plugin manager), lazygit (Git TUI)
- **Declarative**: Brewfile for package management
- **Customizable**: Pure prompt with version display in project directories
- **macOS defaults**: Automatically configures keyboard, trackpad, dock, and display settings

## Technology Stack

| Category | Tool |
|----------|------|
| Version Manager | [mise](https://mise.jdx.dev/) (Node/Python/Ruby/Go) |
| Plugin Manager | [sheldon](https://sheldon.cli.rs/) (Rust-based, fast) |
| Git TUI | [lazygit](https://github.com/jesseduffield/lazygit) |
| Prompt | [pure](https://github.com/sindresorhus/pure) |
| Package Manager | [Homebrew](https://brew.sh/) |

## Quick Start

### One-line Setup

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/tokichie/dotfiles/main/bootstrap.sh)"
```

The script will automatically:
- Clone the dotfiles repository to `~/.dotfiles` (requires git/Xcode Command Line Tools)
- Install all dependencies via Homebrew
- Create symlinks for configuration files
- Set up shell environment

**Note**: You may be prompted for your sudo password when setting the default shell. The script does not require running with `sudo` - it will request elevated privileges only when needed.

### Manual Setup

```bash
# 1. Clone repository
git clone https://github.com/tokichie/dotfiles.git ~/.dotfiles

# 2. Run bootstrap script
cd ~/.dotfiles
./bootstrap.sh

# 3. Restart terminal
exec zsh
```

## What Gets Installed

### CLI Tools
- **Core**: zsh, git, gh, ghq, fzf, jq, yq, tree, direnv, neovim, tmux
- **Version Managers**: mise (replaces rbenv/goenv/pyenv/n)
- **Git**: lazygit, jj (Jujutsu), git-delta
- **Media**: ffmpeg, imagemagick
- **Cloud/Infra**: terraform, tflint, tenv, azure-cli, cloudflared, supabase, gcloud, kubectl, cue
- **Database**: pgcli, libpq
- **API**: buf, grpcurl

### GUI Apps
- **Development**: Visual Studio Code, Cursor, Ghostty
- **Productivity**: Raycast, Obsidian, Notion, Todoist
- **Security**: Bitwarden
- **Database**: DBeaver Community
- **AI**: ChatGPT
- **Utilities**: Karabiner Elements

### macOS System Settings
- **Display**: Maximum scaled resolution
- **Keyboard**: Fastest key repeat, function keys as standard F1-F12
- **Keyboard Remapping**: Caps Lock → Control, Left Control → Escape (via LaunchAgent)
- **Trackpad**: Traditional scroll direction (natural scrolling disabled)
- **Dock**: 45px tile size
- **Screenshots**: Saved to `~/Pictures/ScreenShots/`

## Post-Installation

### Verify Installation

```bash
# Check mise
mise doctor
mise list

# Check sheldon
sheldon list

# Check installed versions
node -v
go version
python --version
ruby -v

# Launch lazygit
lazygit
```

### Test Prompt Display

Navigate to a project directory with `.mise.toml` or `go.mod`:

```bash
cd ~/ghq/github.com/example/project
# Node/Go versions should appear in left prompt
```

### Clean Up Legacy Version Managers

After confirming mise is working correctly, you can remove old version managers:

```bash
# Optional: Remove legacy directories
rm -rf ~/.rbenv ~/.goenv ~/.pyenv ~/.n
```

## Configuration Files

```
~/.dotfiles/
├── bootstrap.sh              # Setup script
├── Brewfile                  # Homebrew dependencies
├── _zshrc                    # Zsh configuration
├── _gitconfig                # Git configuration
├── LaunchAgents/
│   └── com.user.keyremapping.plist  # Keyboard remapping
└── config/
    ├── sheldon/
    │   └── plugins.toml      # Zsh plugins
    ├── lazygit/
    │   └── config.yml        # Lazygit settings
    └── mise/
        └── config.toml       # Version management
```

## Customization

### Add New Packages

Edit `Brewfile` and add:

```ruby
brew "package-name"
cask "app-name"
```

Then run:

```bash
brew bundle --file=~/.dotfiles/Brewfile
```

### Change Version Manager Settings

Edit `~/.config/mise/config.toml`:

```toml
[tools]
node = "20.0.0"  # Specify exact version
python = "latest"
```

Then run:

```bash
mise install
```

### Customize Prompt

Edit `_zshrc` to modify the `pure_prompt_version_info()` function.

### Customize Keyboard Remapping

Edit `LaunchAgents/com.user.keyremapping.plist` to change key mappings. After editing:

```bash
# Reload the LaunchAgent
launchctl unload ~/Library/LaunchAgents/com.user.keyremapping.plist
launchctl load ~/Library/LaunchAgents/com.user.keyremapping.plist

# Verify current mappings
hidutil property --get "UserKeyMapping"
```

Common key codes for `hidutil`:
- Caps Lock: `0x700000039`
- Left Control: `0x7000000E0`
- Right Control: `0x7000000E4`
- Escape: `0x700000029`
- Left Command: `0x7000000E3`
- Right Command: `0x7000000E7`

## Updating

### Update Homebrew Packages

```bash
brew update && brew upgrade
```

### Update Sheldon Plugins

```bash
sheldon lock --update
```

### Update mise Tools

```bash
mise upgrade
```

## Troubleshooting

### Sheldon plugins not loading

```bash
# Reinstall plugins
sheldon lock --update
source ~/.zshrc
```

### mise command not found

```bash
# Ensure mise is activated
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
source ~/.zshrc
```

### Prompt colors not displaying

```bash
# Check if Nerd Font is installed
brew install --cask font-fira-code-nerd-font

# Set terminal font to "FiraCode Nerd Font"
```

## License

MIT

## Author

tokichie
