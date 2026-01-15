#!/bin/bash
#
# bootstrap.sh - Modern dotfiles setup script
# Sets up a complete development environment on macOS
#

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Configuration
readonly DOTFILES_REPO_SSH="git@github.com:tokichie/dotfiles.git"
readonly DOTFILES_REPO_HTTPS="https://github.com/tokichie/dotfiles.git"
readonly DOTFILES_TARGET="$HOME/.dotfiles"

################################################################################
# Logging functions
################################################################################

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

################################################################################
# Phase 0: Setup Dotfiles Repository
################################################################################

setup_dotfiles_repo() {
    # Check if already in the dotfiles directory
    if [ -f "$(pwd)/Brewfile" ] && [ -f "$(pwd)/_zshrc" ]; then
        log_info "Running from dotfiles directory"
        cd "$(pwd)"
        return 0
    fi

    # Check if dotfiles already exists
    if [ -d "$DOTFILES_TARGET" ]; then
        log_info "Dotfiles directory already exists at $DOTFILES_TARGET"
        cd "$DOTFILES_TARGET"
        return 0
    fi

    # Clone dotfiles repository
    log_info "Cloning dotfiles repository..."

    if ! command -v git &> /dev/null; then
        log_error "git is not installed. Please install Xcode Command Line Tools:"
        log_error "  xcode-select --install"
        exit 1
    fi

    # Try SSH first, fallback to HTTPS
    if git clone "$DOTFILES_REPO_SSH" "$DOTFILES_TARGET" 2>/dev/null; then
        log_success "Cloned via SSH"
    elif git clone "$DOTFILES_REPO_HTTPS" "$DOTFILES_TARGET" 2>/dev/null; then
        log_success "Cloned via HTTPS"
    else
        log_error "Failed to clone repository"
        exit 1
    fi

    cd "$DOTFILES_TARGET"
    log_success "Dotfiles repository cloned to $DOTFILES_TARGET"
}

################################################################################
# Phase 1: Homebrew Installation
################################################################################

install_homebrew() {
    log_info "Checking for Homebrew..."

    if command -v brew &> /dev/null; then
        log_success "Homebrew already installed"
        return 0
    fi

    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Setup Homebrew in PATH
    if [[ $(uname -m) == 'arm64' ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        eval "$(/usr/local/bin/brew shellenv)"
    fi

    log_success "Homebrew installed"
}

################################################################################
# Phase 2: Install Dependencies via Brewfile
################################################################################

install_dependencies() {
    log_info "Installing dependencies via Brewfile..."

    if [ ! -f "$(pwd)/Brewfile" ]; then
        log_error "Brewfile not found at $(pwd)/Brewfile"
        exit 1
    fi

    brew bundle --file="$(pwd)/Brewfile"

    log_success "Dependencies installed"
}

################################################################################
# Phase 3: Create Symlinks
################################################################################

create_symlinks() {
    log_info "Creating symlinks..."

    # Symlink dotfiles (_filename -> ~/.filename)
    for file in "$(pwd)"/_*; do
        [ -f "$file" ] || continue

        local basename=$(basename "$file" | sed 's/^_/./')
        local target="$HOME/$basename"

        if [ -L "$target" ]; then
            log_info "Symlink already exists: $basename"
        elif [ -e "$target" ]; then
            log_warning "Backing up existing $basename to ${basename}.backup"
            mv "$target" "${target}.backup"
            ln -s "$file" "$target"
            log_success "Created symlink: $basename"
        else
            ln -s "$file" "$target"
            log_success "Created symlink: $basename"
        fi
    done

    # Symlink config directories
    mkdir -p "$HOME/.config"

    for dir in "$(pwd)/config"/*; do
        [ -d "$dir" ] || continue

        local dirname=$(basename "$dir")
        local target="$HOME/.config/$dirname"

        if [ -L "$target" ]; then
            log_info "Config symlink already exists: $dirname"
        elif [ -e "$target" ]; then
            log_warning "Backing up existing config/$dirname to ${target}.backup"
            mv "$target" "${target}.backup"
            ln -s "$dir" "$target"
            log_success "Created config symlink: $dirname"
        else
            ln -s "$dir" "$target"
            log_success "Created config symlink: $dirname"
        fi
    done
}

################################################################################
# Phase 4: Initialize Sheldon
################################################################################

initialize_sheldon() {
    log_info "Initializing sheldon plugins..."

    if ! command -v sheldon &> /dev/null; then
        log_error "sheldon not found. Please ensure Homebrew installation completed."
        exit 1
    fi

    log_info "Downloading and installing zsh plugins (this may take a while)..."
    sheldon lock --update

    log_success "Sheldon plugins installed"
}

################################################################################
# Phase 5: Initialize mise
################################################################################

initialize_mise() {
    log_info "Installing tools via mise..."

    if ! command -v mise &> /dev/null; then
        log_error "mise not found. Please ensure Homebrew installation completed."
        exit 1
    fi

    # mise reads from ~/.config/mise/config.toml (symlinked)
    log_info "Installing Node.js, Python, Ruby, Go (this may take several minutes)..."
    mise install
    mise reshim

    log_success "mise tools installed"
}

################################################################################
# Phase 6: Install Google Cloud SDK
################################################################################

install_google_cloud_sdk() {
    log_info "Installing Google Cloud SDK..."

    if [ -d "$HOME/google-cloud-sdk" ]; then
        log_success "Google Cloud SDK already installed"
        return 0
    fi

    log_info "Downloading and installing Google Cloud SDK (this may take a few minutes)..."
    curl https://sdk.cloud.google.com | bash -s -- --disable-prompts --install-dir="$HOME"

    log_success "Google Cloud SDK installed"
    log_warning "Please restart your terminal to enable gcloud command"
}

################################################################################
# Phase 7: Set Zsh as Default Shell
################################################################################

set_default_shell() {
    local zsh_path
    zsh_path=$(command -v zsh)

    if [ "$SHELL" = "$zsh_path" ]; then
        log_success "Zsh is already the default shell"
        return 0
    fi

    log_info "Setting zsh as default shell..."

    # Add zsh to allowed shells if not present
    if ! grep -q "$zsh_path" /etc/shells; then
        log_info "Adding $zsh_path to /etc/shells (requires sudo password)"

        # Temporarily disable exit-on-error for sudo operations
        set +e
        echo "$zsh_path" | sudo tee -a /etc/shells > /dev/null 2>&1
        local sudo_exit_code=$?
        set -e

        if [ $sudo_exit_code -ne 0 ]; then
            log_warning "Failed to add $zsh_path to /etc/shells"
            log_warning "You may need to run this manually:"
            log_warning "  echo '$zsh_path' | sudo tee -a /etc/shells"
            return 1
        fi
    fi

    # Change default shell
    set +e
    chsh -s "$zsh_path" 2>/dev/null
    local chsh_exit_code=$?
    set -e

    if [ $chsh_exit_code -eq 0 ]; then
        log_success "Default shell changed to zsh"
        log_warning "Please restart your terminal for changes to take effect"
    else
        log_warning "Failed to change default shell automatically"
        log_warning "Please run this command manually:"
        log_warning "  chsh -s $zsh_path"
    fi
}

################################################################################
# Phase 8: Configure macOS Defaults
################################################################################

set_max_scaled_resolution() {
    log_info "Setting display to maximum scaled resolution..."

    if ! command -v displayplacer &> /dev/null; then
        log_warning "displayplacer not found, skipping display configuration"
        return 0
    fi

    # Get display list output
    local display_info=$(displayplacer list)

    # Get first display ID
    local display_id=$(echo "$display_info" | grep "Persistent screen id" | head -1 | awk '{print $4}')

    # Extract first display's info only (from first "Persistent screen id" to second one, or to end)
    local first_display_info=$(echo "$display_info" | awk 'BEGIN {count=0} /^Persistent screen id:/ {count++; if (count==2) exit} count==1 {print}')

    # Get max resolution with scaling:on for first display only
    # Parse resolution lines with scaling:on, extract resolution, sort by width*height
    local max_res=$(echo "$first_display_info" | \
        grep "scaling:on" | \
        grep -o "res:[0-9]*x[0-9]*" | \
        sed 's/res://' | \
        awk -F'x' '{print $1*$2, $0}' | \
        sort -rn | \
        head -1 | \
        awk '{print $2}')

    if [ -z "$max_res" ]; then
        log_warning "Could not determine maximum scaled resolution"
        return 0
    fi

    log_info "Setting display to ${max_res} (scaled)"

    # Apply the resolution
    displayplacer "id:${display_id} res:${max_res} hz:60 color_depth:8 enabled:true scaling:on origin:(0,0) degree:0"

    log_success "Display resolution configured to ${max_res}"
}

configure_macos() {
    log_info "Configuring macOS system preferences..."

    # Display resolution
    set_max_scaled_resolution

    # Keyboard settings
    log_info "Setting keyboard repeat rate..."
    defaults write NSGlobalDomain KeyRepeat -int 1
    defaults write NSGlobalDomain InitialKeyRepeat -int 15
    log_success "Keyboard settings configured"

    # Trackpad settings
    log_info "Setting trackpad scroll direction..."
    defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
    log_success "Trackpad settings configured"

    # Dock settings
    log_info "Configuring Dock..."
    defaults write com.apple.dock tilesize -int 45
    killall Dock
    log_success "Dock settings configured"

    # Screenshot settings
    log_info "Configuring screenshot location..."
    mkdir -p "$HOME/Pictures/ScreenShots"
    defaults write com.apple.screencapture location "$HOME/Pictures/ScreenShots"
    killall SystemUIServer
    log_success "Screenshot settings configured"

    log_warning "Some settings require logging out and back in to take full effect"
}

################################################################################
# Main
################################################################################

main() {
    echo ""
    echo "========================================="
    echo "  Dotfiles Bootstrap"
    echo "========================================="
    echo ""
    log_info "This script will set up your development environment."
    log_info "You may be prompted for your sudo password when setting the default shell."
    echo ""

    setup_dotfiles_repo
    install_homebrew
    install_dependencies
    create_symlinks
    initialize_sheldon
    initialize_mise
    install_google_cloud_sdk

    # Set default shell (may require sudo, handle failure gracefully)
    set +e
    set_default_shell
    set -e

    # Configure macOS defaults
    configure_macos

    echo ""
    echo "========================================="
    log_success "Bootstrap completed!"
    echo "========================================="
    echo ""
    echo "Next steps:"
    echo "  1. Restart your terminal (or run 'exec zsh')"
    echo "  2. Log out and log back in for all macOS settings to take effect"
    echo "  3. Verify installation with: mise doctor"
    echo "  4. (Optional) Clean up old version managers:"
    echo "     rm -rf ~/.rbenv ~/.goenv ~/.pyenv ~/.n"
    echo ""
}

# Run main function
main "$@"
