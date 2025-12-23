#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# macOS Developer Setup Script
# Author: Ushe
# Description: Idempotent setup script for a new Mac
# Usage: ./setup.sh [--ssh-1password | --ssh-file]
# =============================================================================

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SSH_MODE="${1:---ssh-1password}"  # Default to 1Password SSH

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; }

# =============================================================================
# PREFLIGHT CHECKS
# =============================================================================
preflight() {
    log_info "Running preflight checks..."

    if [[ "$(uname)" != "Darwin" ]]; then
        log_error "This script is for macOS only"
        exit 1
    fi

    if ! command -v brew &> /dev/null; then
        log_error "Homebrew not found. Install it first: https://brew.sh"
        exit 1
    fi

    log_success "Preflight checks passed"
}

# =============================================================================
# HOMEBREW PACKAGES
# =============================================================================
install_packages() {
    log_info "Installing Homebrew packages..."

    brew bundle --file="$DOTFILES_DIR/Brewfile"

    log_success "Homebrew packages installed"
}

# =============================================================================
# OH-MY-ZSH
# =============================================================================
setup_ohmyzsh() {
    log_info "Setting up oh-my-zsh..."

    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        log_warn "oh-my-zsh already installed, skipping"
    else
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        log_success "oh-my-zsh installed"
    fi

    # External plugins
    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
        log_success "zsh-autosuggestions installed"
    fi

    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
        log_success "zsh-syntax-highlighting installed"
    fi

    if [[ ! -d "$ZSH_CUSTOM/plugins/fzf-tab" ]]; then
        git clone https://github.com/Aloxaf/fzf-tab "$ZSH_CUSTOM/plugins/fzf-tab"
        log_success "fzf-tab installed"
    fi
}

# =============================================================================
# SSH SETUP - FILE BASED
# =============================================================================
setup_ssh_file() {
    log_info "Setting up SSH (file-based)..."

    SSH_KEY="$HOME/.ssh/id_ed25519"

    if [[ -f "$SSH_KEY" ]]; then
        log_warn "SSH key already exists at $SSH_KEY, skipping generation"
    else
        mkdir -p "$HOME/.ssh"
        chmod 700 "$HOME/.ssh"

        read -p "Enter email for SSH key: " ssh_email
        ssh-keygen -t ed25519 -C "$ssh_email" -f "$SSH_KEY"

        # Start ssh-agent and add key
        eval "$(ssh-agent -s)"

        # Create SSH config for macOS keychain integration
        cat > "$HOME/.ssh/config" << 'EOF'
Host *
    AddKeysToAgent yes
    UseKeychain yes
    IdentityFile ~/.ssh/id_ed25519

Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
EOF

        ssh-add --apple-use-keychain "$SSH_KEY"

        log_success "SSH key generated"
        echo ""
        log_info "Add this public key to GitHub:"
        echo ""
        cat "$SSH_KEY.pub"
        echo ""
    fi
}

# =============================================================================
# SSH SETUP - 1PASSWORD
# =============================================================================
setup_ssh_1password() {
    log_info "SSH via 1Password..."
    echo ""
    log_info "Configure SSH in 1Password:"
    echo "  1. Open 1Password → Settings → Developer"
    echo "  2. Enable 'Use the SSH Agent'"
    echo "  3. Set up SSH keys via GitHub integration (1Password will create ~/.ssh/config)"
    echo ""
    log_success "See: https://developer.1password.com/docs/ssh/get-started"
}

# =============================================================================
# GIT CONFIG
# =============================================================================
setup_git() {
    log_info "Setting up Git..."

    read -p "Enter Git user name: " git_name
    read -p "Enter Git email: " git_email

    git config --global user.name "$git_name"
    git config --global user.email "$git_email"

    # Core settings
    git config --global init.defaultBranch main
    git config --global core.editor "nvim"
    git config --global pull.rebase true
    git config --global fetch.prune true
    git config --global diff.colorMoved zebra

    # SSH Signing
    if [[ "$SSH_MODE" == "--ssh-1password" ]]; then
        log_info "Configuring Git for 1Password SSH signing..."
        git config --global gpg.format ssh
        git config --global gpg.ssh.program "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
        git config --global commit.gpgsign true
        echo ""
        log_info "Paste your public key from 1Password (starts with ssh-ed25519):"
        read -r signing_key
        if [[ -n "$signing_key" ]]; then
            git config --global user.signingkey "$signing_key"
            log_success "Signing key configured"
        else
            log_warn "No key entered - set it later with: git config --global user.signingkey \"ssh-ed25519 AAAA...\""
        fi
    else
        log_info "Configuring Git for file-based SSH signing..."
        git config --global gpg.format ssh
        git config --global user.signingkey "$HOME/.ssh/id_ed25519.pub"
        git config --global commit.gpgsign true
    fi

    # Aliases
    git config --global alias.co checkout
    git config --global alias.br branch
    git config --global alias.ci commit
    git config --global alias.st status
    git config --global alias.lg "log --oneline --graph --decorate"
    git config --global alias.last "log -1 HEAD"
    git config --global alias.unstage "reset HEAD --"

    log_success "Git configured"
}

# =============================================================================
# TMUX
# =============================================================================
setup_tmux() {
    log_info "Setting up tmux..."

    # Install TPM (Tmux Plugin Manager)
    if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
        log_success "TPM installed"
    else
        log_warn "TPM already installed"
    fi

    log_success "tmux configured"
    log_info "Run 'prefix + I' inside tmux to install plugins"
}

# =============================================================================
# STOW DOTFILES
# =============================================================================
stow_packages() {
    log_info "Stowing dotfiles..."

    # Backup existing files that would conflict
    for file in "$HOME/.zshrc" "$HOME/.tmux.conf"; do
        if [[ -f "$file" && ! -L "$file" ]]; then
            mv "$file" "$file.bak.$(date +%s)"
            log_warn "Backed up existing $(basename "$file")"
        fi
    done

    # Backup existing nvim config if not a symlink
    if [[ -d "$HOME/.config/nvim" && ! -L "$HOME/.config/nvim" ]]; then
        mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak.$(date +%s)"
        log_warn "Backed up existing nvim config"
    fi

    mkdir -p "$HOME/.config"

    # Stow all packages
    cd "$DOTFILES_DIR"
    stow -v -R -t "$HOME" zsh tmux starship colima nvim ghostty

    log_success "Dotfiles stowed"
}

# =============================================================================
# FZF
# =============================================================================
setup_fzf() {
    log_info "Setting up fzf key bindings..."

    # Install fzf key bindings and completion
    "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc --no-bash --no-fish

    log_success "fzf configured"
}


# =============================================================================
# MACOS DEFAULTS
# =============================================================================
setup_macos_defaults() {
    log_info "Setting macOS defaults..."

    # Keyboard: fast key repeat
    defaults write NSGlobalDomain KeyRepeat -int 2
    defaults write NSGlobalDomain InitialKeyRepeat -int 15

    # Finder: show hidden files
    defaults write com.apple.finder AppleShowAllFiles -bool true

    # Finder: show path bar
    defaults write com.apple.finder ShowPathbar -bool true

    # Finder: show status bar
    defaults write com.apple.finder ShowStatusBar -bool true

    # Dock: auto-hide
    defaults write com.apple.dock autohide -bool true

    # Dock: faster auto-hide animation
    defaults write com.apple.dock autohide-delay -float 0
    defaults write com.apple.dock autohide-time-modifier -float 0.4

    # Dock: minimize to application
    defaults write com.apple.dock minimize-to-application -bool true

    # Trackpad: tap to click
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

    # Screenshots: save to ~/Screenshots
    mkdir -p "$HOME/Screenshots"
    defaults write com.apple.screencapture location -string "$HOME/Screenshots"

    # Restart affected apps
    killall Finder Dock

    log_success "macOS defaults set"
}

# =============================================================================
# MAIN
# =============================================================================
main() {
    echo ""
    echo "=============================================="
    echo "  macOS Developer Setup"
    echo "  Mode: $SSH_MODE"
    echo "=============================================="
    echo ""

    preflight
    install_packages
    setup_ohmyzsh
    setup_fzf

    if [[ "$SSH_MODE" == "--ssh-1password" ]]; then
        setup_ssh_1password
    else
        setup_ssh_file
    fi

    setup_git
    setup_tmux
    stow_packages

    read -p "Apply macOS system defaults? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        setup_macos_defaults
    fi

    echo ""
    log_success "Setup complete!"
    echo ""
    log_info "Next steps:"
    echo "  1. Restart your terminal (or run: source ~/.zshrc)"
    echo "  2. Open nvim to install plugins"
    echo "  3. Run 'tmux' then press 'prefix + I' to install tmux plugins"
    echo "  4. Run 'colima start' to start Docker"
    echo "  5. Add SSH public key to GitHub"
    echo ""
}

main "$@"
