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

echo "Dotfiles were installed."

