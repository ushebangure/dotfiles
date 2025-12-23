# =============================================================================
# ZSH Configuration
# =============================================================================

# Path to oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Theme (disabled - using Starship)
ZSH_THEME=""

# Plugins
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    fzf-tab
    docker
    kubectl
    aws
)

source $ZSH/oh-my-zsh.sh

# =============================================================================
# Environment Variables
# =============================================================================

export EDITOR="nvim"
export VISUAL="nvim"
export LANG="en_US.UTF-8"

# Go
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# =============================================================================
# Tool Initialization
# =============================================================================

# Starship prompt
eval "$(starship init zsh)"

# Zoxide (smarter cd)
eval "$(zoxide init zsh)"

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# =============================================================================
# FZF Configuration
# =============================================================================

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

# Preview with bat
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"

# =============================================================================
# Aliases
# =============================================================================

# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# Modern replacements
alias ls="eza --icons"
alias ll="eza -la --icons --git"
alias la="eza -a --icons"
alias lt="eza --tree --level=2 --icons"
alias cat="bat"
alias find="fd"
alias grep="rg"

# Git
alias g="git"
alias gs="git status"
alias gc="git commit"
alias gp="git push"
alias gl="git pull"
alias gd="git diff"
alias gco="git checkout"
alias gb="git branch"
alias glog="git log --oneline --graph --decorate"
alias lg="lazygit"

# Docker & K8s
alias d="docker"
alias dc="docker compose"
alias k="kubectl"
alias kx="kubectx"
alias kn="kubens"
alias ld="lazydocker"

# Neovim
alias v="nvim"
alias vim="nvim"

# Tmux
alias t="tmux"
alias ta="tmux attach"
alias tn="tmux new -s"

# Colima
alias colima-start="colima start --cpu 4 --memory 8"

# =============================================================================
# Functions
# =============================================================================

# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Find and open in nvim
vf() {
    local file
    file=$(fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}')
    [[ -n "$file" ]] && nvim "$file"
}

# Git branch fuzzy checkout
gcob() {
    local branch
    branch=$(git branch -a | fzf | sed 's/remotes\/origin\///' | xargs)
    [[ -n "$branch" ]] && git checkout "$branch"
}

# Kill process by port
killport() {
    lsof -ti:$1 | xargs kill -9
}
