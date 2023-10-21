#!/bin/bash
# Heavily inspired by https://github.com/daler/dotfiles

GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
BLUE="\e[34m"
UNSET="\e[0m"

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

export PS1=

# VERSIONS
NVIM_VERSION=0.9.4

# PATH TO INSTALL OPT AND BIN
LOCAL_BIN=$HOME/.local/bin
LOCAL_OPT=$HOME/.local/opt
XDG_CONFIG_HOME=$HOME/.config

mkdir -p $LOCAL_BIN
mkdir -p $LOCAL_OPT
mkdir -p $XDG_CONFIG_HOME

set -eo pipefail


# Depending on the system, we may have curl or wget but not both -- so try to
# figure it out.
try_curl() {
    url=$1; dest=$2; command -v curl > /dev/null && curl -fL $url > $dest
}
try_wget() {
    url=$1; dest=$2; command -v wget > /dev/null && wget -O- $url > $dest
}

# Generic download function
download() {
    echo "Downloading $1 to $2"
    [[ -e $(dirname $2) ]] || mkdir -p $(dirname $2)
    if ! (try_curl $1 $2 || try_wget $1 $2); then
        echo "Could not download $1"
    fi
}


# Append a line to the end of a file, but only if the line isn't already there
add_line_to_file () {
    line=$1
    file=$2
    if [ ! -e "$file" ]; then
        echo "$line" >> $file
    elif grep -vq "$line" $file; then
        echo "$line" >> $file
    fi
}


# Prompt user for info ($1 is text to provide)
ok () {
    # If the DOTFILES_FORCE=true env var was set, then no need to ask, we want
    # to always say yes
    if [ $DOTFILES_FORCE = "true" ]; then
        return 0
    fi
    printf "${GREEN}$1${UNSET}\n"
    read -p "Continue? (y/[n]) " -n 1 REPLY;
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        return 0
    fi
    printf "${RED}Exiting.${UNSET}\n"
    return 1
}


function copy_dotfiles() {
    set -x

    ok "Copies over all the dotfiles here to your home directory.
    - A backup will be made in $BACKUP_DIR
    - List of files that will be copied is in 'include.files'
    - Prompts again before actually running to make sure!"

    function actually_copy_dotfiles() {
        files=".bashrc .bash_profile .config/.dircolors .config/git-prompt.sh"
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
            echo "Creating symlink: $hf --> $DOTFILES_DIR/home/$f"
            ln -sf "$DOTFILES_DIR/home/$f" "$hf"
        done
        unset f
        unset files
    }

    if [ $DOTFILES_FORCE == "true" ]; then
        actually_copy_dotfiles
    else
        read -p "This may overwrite existing files in your home directory. Backups will be put in $BACKUP_DIR. Are you sure? (y/n) " -n 1;
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            actually_copy_dotfiles
        fi
    fi
    unset actually_copy_dotfiles    
}


function install_tmux() {
    ok "Install tmux and setup its config"
    sudo apt-get install -y tmux
    mkdir -p ~/.config/tmux
    ln -sf $DOTFILES_DIR/home/.config/tmux/tmux.conf $HOME/.config/tmux/tmux.conf
}


function install_neovim() {
    ok "Downloads neovim tarball from https://github.com/neovim/neovim, install into $HOME/opt/bin/neovim"
    if [[ $OSTYPE == darwin* ]]; then
        download https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/nvim-macos.tar.gz nvim-macos.tar.gz
        tar -xzf nvim-macos.tar.gz
        mv nvim-macos $LOCAL_OPT
    else
        download https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/nvim-linux64.tar.gz nvim-linux64.tar.gz
        tar -xzf nvim-linux64.tar.gz
        mv nvim-linux64 $LOCAL_OPT/neovim
        rm nvim-linux64.tar.gz
    fi
    ln -sf $LOCAL_OPT/neovim/bin/nvim $LOCAL_BIN/nvim
    printf "${YELLOW}- installed neovim to $LOCAL_OPT/neovim${UNSET}\n"
    printf "${YELLOW}- created symlink $LOCAL_BIN/nvim${UNSET}\n"
}


while [[ "$#" -gt 0 ]]; do
    case $1 in
        --dotfiles) 
            copy_dotfiles
            shift
            ;;
        --tmux) 
            install_tmux
            shift
            ;;
        --nvim|--neovim)
            install_tmux
            shift
            ;;
        --all)
            copy_dotfiles
            install_tmux
            install_neovim
            ;;
        *) 
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done