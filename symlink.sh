## Symlink my dotfiles

cwd="$PWD"

# Vim/Nvim
ln -s "$cwd"/.config/nvim/init.vim ~/.config/nvim/init.vim
ln -s ~/.config/nvim/init.vim ~/.vimrc
ln -s "$cwd"/.config/nvim/plugin ~/.config/nvim/plugin

# Zsh
ln -s "$cwd"/zshrc ~/.zshrc
# ln -s "$cwd"/zsh/.zsh-plugins ~/.zsh-plugins
# ln -s "$cwd"/zsh/.zprofile ~/.zprofile
# ln -s "$cwd"/zsh/.zshenv ~/.zshenv
# ln -s "$cwd"/zsh/.zshrc ~/.zshrc
