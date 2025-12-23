# Dotfiles

macOS developer environment setup for a Principal Engineer / CTO workflow.

## What's Included

| Category | Tools |
|----------|-------|
| Shell | zsh, oh-my-zsh, starship prompt |
| Terminal | Ghostty |
| Editor | Neovim (LazyVim), tmux |
| Languages | Go, Node.js, Python |
| Containers | Docker (Colima), kubectl, kubectx, helm, k9s |
| Cloud | AWS CLI |
| Git | git, gh, lazygit |
| Search | fzf, ripgrep, fd, bat, eza, zoxide |
| Extras | jq, yq, tldr, htop, lazydocker |

## Prerequisites

- macOS
- [Homebrew](https://brew.sh) installed
- [1Password](https://1password.com) for SSH key management (default)

## Installation

```bash
# Clone and run
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup.sh

# OR with file-based SSH (no 1Password)
./setup.sh --ssh-file
```

## Post-Installation

1. **Restart terminal** or `source ~/.zshrc`
2. **Neovim**: Run `nvim` to install plugins
3. **Tmux**: Run `tmux`, then `prefix + I` to install plugins
4. **Docker**: Run `colima start`
5. **GitHub**: Add SSH public key to GitHub

## File Structure

Uses [GNU Stow](https://www.gnu.org/software/stow/) for symlink management. Each directory is a "package" that mirrors `$HOME`:

```
dotfiles/
├── setup.sh              # Main setup script
├── Brewfile              # Homebrew packages
├── zsh/
│   └── .zshrc            # → ~/.zshrc
├── tmux/
│   └── .tmux.conf        # → ~/.tmux.conf
├── starship/
│   └── .config/
│       └── starship.toml # → ~/.config/starship.toml
├── colima/
│   └── .colima/
│       └── default/
│           └── colima.yaml # → ~/.colima/default/colima.yaml
├── nvim/
│   └── .config/
│       └── nvim/         # → ~/.config/nvim/ (LazyVim)
│           ├── init.lua
│           └── lua/
│               ├── config/
│               └── plugins/
├── ghostty/
│   └── .config/
│       └── ghostty/
│           └── config    # → ~/.config/ghostty/config
└── README.md
```

### Manual Stow Usage

```bash
cd ~/dotfiles
stow zsh          # Symlink zsh config
stow -D zsh       # Remove symlinks
stow -R zsh       # Restow (refresh)
stow */           # Stow all packages
```

## SSH Options

### 1Password (default)
- Set up via 1Password → Settings → Developer → SSH Agent
- GitHub integration creates `~/.ssh/config` automatically
- Biometric unlock for git operations
- See: https://developer.1password.com/docs/ssh/get-started

### File-based (`--ssh-file`)
- Generates `~/.ssh/id_ed25519`
- Uses macOS Keychain for passphrase
- Configures Git SSH signing

## Key Bindings

### Tmux (prefix = Ctrl+Space)
| Key | Action |
|-----|--------|
| `prefix + \|` | Split vertical |
| `prefix + -` | Split horizontal |
| `prefix + h/j/k/l` | Navigate panes |
| `prefix + r` | Reload config |
| `prefix + I` | Install plugins |

### Zsh/FZF
| Key | Action |
|-----|--------|
| `Ctrl+R` | Fuzzy history search |
| `Ctrl+T` | Fuzzy file finder |
| `Alt+C` | Fuzzy cd |

### Custom Functions
| Command | Action |
|---------|--------|
| `vf` | Fuzzy find + open in nvim |
| `gcob` | Fuzzy git branch checkout |
| `mkcd <dir>` | mkdir + cd |
| `killport <port>` | Kill process on port |

## Aliases

```bash
# Modern replacements
ls → eza --icons
cat → bat
find → fd
grep → rg

# Git
lg → lazygit
gs → git status
glog → git log --oneline --graph

# Docker/K8s
k → kubectl
kx → kubectx
ld → lazydocker
```

## Customization

```bash
# Edit configs, then restow
nvim ~/dotfiles/zsh/.zshrc
nvim ~/dotfiles/tmux/.tmux.conf
nvim ~/dotfiles/starship/.config/starship.toml

# Restow after changes (usually not needed, symlinks just work)
cd ~/dotfiles && stow -R zsh tmux starship
```
