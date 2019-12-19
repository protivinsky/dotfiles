#!/bin/bash

# list of files we want to move


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

# and install my favourite vim plugins
if [ ! -d $HOME/.vim/pack/vendor/start/nerdtree ]; then
    git clone https://github.com/scrooloose/nerdtree.git $HOME/.vim/pack/vendor/start/nerdtree
    vim -u NONE -c "helptags $HOME/.vim/pack/vendor/start/nerdtree/doc" -c q
fi

if [ ! -d $HOME/.vim/pack/vendor/start/vimteractive ]; then
    git clone https://github.com/protivinsky/vimteractive.git $HOME/.vim/pack/vendor/start/vimteractive
fi

echo "Dotfiles were installed."

