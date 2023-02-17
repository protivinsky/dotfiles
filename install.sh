#!/bin/bash


echo "Creating symlinks to dotfiles."
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
files=".bashrc .bash_profile .gitconfig .tmux.conf .vimrc .vim"

for f in $files; do
    hf=$HOME/$f
    if [ -r $hf ] && [ ! -h $hf ]; then
        # file already exists at $HOME and is not a symlink
        # copy it into .back with timestamp
        if [ ! -d $HOME/.back ]; then
            mkdir $HOME/.back
        fi
        echo "Moving: $hf -> $HOME/.back"
        mv $hf $HOME/.back/$f.$(date '+%Y-%m-%d_%H-%M-%S')
    fi
    echo "Creating symlink: $hf --> $DOTFILES_DIR/$f"
    ln -sf "$DOTFILES_DIR/$f" "$hf"
done

# Install some prerequisities for YouCompleteMe - do I mind installing it everywhere?
sudo apt install build-essential cmake python3-dev mono-complete golang nodejs openjdk-17-jdk openjdk-17-jre npm

# and install Vundle, it handles the rest
if [ ! -d $HOME/.vim/bundle/Vundle.vim ]; then
    echo "Cloning Vundle."
    git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim
fi

echo "Installing vim plugins with Vundle."
vim +PluginInstall +qall

echo "Dotfiles were installed."

