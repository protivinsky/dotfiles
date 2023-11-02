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
# sudo apt-get update

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
    if [[ -v DOTFILES_FORCE && $DOTFILES_FORCE -eq 1 ]]; then
        return 0
    fi
    printf "${GREEN}$1${UNSET}\n"
    read -p "Continue? (y/[n]) " -n 1 REPLY;
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        return 0
    fi
    echo
    printf "${RED}Exiting.${UNSET}\n"
    return 1
}


clone_if_not_exists() {
    # make it more robust to transient network issues (seeing many of these...)
    if [ ! -d "$2" ]; then
      # Directory doesn't exist. Clone the repo.
      git clone "$1" "$2"
    else
      # Directory exists. Navigate to it and pull the latest changes.
      CURRENT_DIR=$(pwd)
      cd "$2" || exit
      git pull origin master
      cd $CURRENT_DIR
    fi 
}


function copy_dotfiles() {
    ok "Copies over all the dotfiles here to your home directory.
    - A backup will be made in $BACKUP_DIR
    - List of files that will be copied is in 'include.files'
    - Prompts again before actually running to make sure!"

    files=".bashrc .bash_profile .gitconfig .config/.dircolors .config/git-prompt.sh"
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


function install_tmux() {
    ok "Install tmux and setup its config"
    sudo apt-get install -y tmux
    mkdir -p $HOME/.config/tmux
    ln -sf $DOTFILES_DIR/home/.config/tmux/tmux.conf $HOME/.config/tmux/tmux.conf
    mkdir -p $HOME/.tmux/plugins
    clone_if_not_exists https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
    $HOME/.tmux/plugins/tpm/bin/install_plugins
    
    # try to fix the catpuccin plugin, to get better names in tabs
    sed -i "s|local text=\"\$(get_tmux_option \"@catppuccin_window_current_text\" \"#{b:pane_current_path}\")\"|local text=\"\$(get_tmux_option \"@catppuccin_window_current_text\" \"#W [#\(echo '#{pane_current_path}' \| rev \| cut -d'/' -f-2 \| rev\)]\")\"|g" .config/tmux/plugins/tmux/window/window_current_format.sh
    printf "${YELLOW}- patching the catpuccin/tmux plugin win titles${UNSET}\n"
}


function install_neovim() {
    ok "Downloads neovim tarball from https://github.com/neovim/neovim, install into $LOCAL_OPT/neovim and create symlink $LOCAL_BIN/nvim"
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

    # install kickstart nvim config
    clone_if_not_exists http://github.com/nvim-lua/kickstart.nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim
}


function install_python() {
    ok "Installing python3 and python3-venv and create symlink $LOCAL_BIN/python"
    sudo apt-get install -y python3 python3-venv
    printf "${YELLOW}- installed python3 and python3-venv ${UNSET}\n"
    ln -sf $(which python3) $LOCAL_BIN/python
    printf "${YELLOW}- created symlink $LOCAL_BIN/python${UNSET}\n"
}


function install_apt() {
    ok "Installing additional packages"
    sudo apt-get install -y build-essential wget curl htop rsync stow
}


while [[ "$#" -gt 0 ]]; do
    case $1 in
        -y|--yes) 
            DOTFILES_FORCE=true
            shift
            ;;
        --dotfiles) 
            copy_dotfiles
            shift
            ;;
        --tmux) 
            install_tmux
            shift
            ;;
        --nvim|--neovim)
            install_neovim
            shift
            ;;
        --python)
            install_python
            shift
            ;;
        --apt)
            install_apt
            shift
            ;; 
        --all)
            copy_dotfiles
            if ! command -v tmux > /dev/null 2>&1; then
              install_tmux; fi
            install_neovim
            if ! command -v neovim > /dev/null 2>&1; then
              install_neovim; fi
            install_python
            # install_apt
            exit 1
            ;;
        *) 
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# source $HOME/.bashrc

