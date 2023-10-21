#!/bin/bash
# Heavily inspired by https://github.com/daler/dotfiles

GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
BLUE="\e[34m"
UNSET="\e[0m"

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


# Since some commands affect .bashrc, it's most convenient to source it within
# this script
if [ -e ~/.bashrc ]; then
    source ~/.bashrc
fi

set -eo pipefail


function showHelp() {

    function header() {
        # Print a dashed line followed by yellow text
        echo "----------------------------------------------------------------------------"
        printf "${YELLOW}$1${UNSET}\n"
    }

    function cmd() {
        # Prints nicely-formatted command help.
        #
        # First argument is the command (like "--install-prog").
        #
        # All subsequent arguments will be joined together and will comprise
        # the description.

        label="  ${GREEN}$1${UNSET}"

        # Note that "." is used here as a placeholder instead of " ". It was
        # challenging to get whitespace to work correctly with the sed
        # commands. So the padding is only converted to spaces at the very end.

        # This converts the provided arg ('--install-prog') into dots
        pad_cmd=$(echo $1 | sed 's/[a-zA-Z\-]/./g')

        # This is the full size of the padding, used for all lines but the
        # first.
        pad_full="........................."

        # Calculate padding for the first line by deleting the number of
        # characters used by the command, plus two (for the leading 2 spaces
        # added to $label above)
        pad1=$(echo $pad_full | sed 's/'"$pad_cmd"'..//' | sed 's/./ /g')

        # The full padding is converted to spaces.
        pad2=$(echo $pad_full | sed 's/./ /g')

        # Concat all args but the first (${@:2}), format them to 60 spaces
        # using the built-in `fmt`, and then use awk to use pad1 for the first
        # line and pad2 for subsequent lines
        desc=$(echo "${@:2}" \
            | fmt -w 60 \
            | awk -v pad1="$pad1" -v pad2="$pad2" \
            'NR==1{print pad1$0} NR >1 {print pad2$0}')
        printf "$label$desc\n\n"
    }

    echo
    printf "${YELLOW}Usage:${UNSET}\n\n"
    echo "   $0 [ARGUMENT]"
    echo
    echo "     - Options are intended to be run one-at-a-time."
    echo "     - Each command will prompt if you want to continue."
    echo "     - Set the env var DOTFILES_FORCE=true if you want always say yes."
    echo

    header "RECOMMENDED ORDER:"
    echo "    1)  ./setup.sh --dotfiles"
    echo "    2)  CLOSE TERMINAL, OPEN A NEW ONE"
    echo "    3)  ./setup.sh --install-tmux"
    echo "    4)  ./setup.sh --install-neovim"
    echo ""
    echo "  Then browse the other options below to see what else is available/useful."

    header "dotfiles:"

    cmd "--diffs" \
        "Inspect diffs between repo and home"

    cmd "--vim-diffs" \
        "Inspect diffs between repo and home, using vim -d"

    cmd "--dotfiles" \
        "Replaces files in $HOME with files from this directory"

    header "General setup:"

    cmd "--apt-install" \
        "Local Linux only, needs root. Install a bunch of useful Ubuntu" \
        "packages. See apt-installs.txt for list, and edit if needed."

    cmd "--install-neovim" \
        "neovim is a drop-in replacement for vim, with additional features" \
        "Homepage: https://neovim.io/"

    cmd "--install-tmux" \
        "Install tmux"

    echo
}

# Deal with possibly-unset variables before we do set -u
if [ -z $1 ]; then
    showHelp | less -R
    exit 0
fi

if [ -z $DOTFILES_FORCE ]; then
    DOTFILES_FORCE=false
fi

set -eo pipefail

# The CLI is pretty minimal -- we're just doing an exact string match
task=$1


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


# TASKS ----------------------------------------------------------------------
#
# Each task asks if it's OK to run; that also serves as documentation for each
# task.

if [ $task == "--apt-install" ]; then
    ok "Installs packages from the file apt-installs.txt"
    sudo apt-get update && \
    sudo apt-get install -y $(awk '{print $1}' apt-installs.txt | grep -v "^#")

elif [ $task == "--install-neovim" ]; then
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


# TMUX
elif [ $task == "--install-tmux" ]; then
    ok "Install tmux and setup its config"
    sudo apt-get install -y tmux
    mkdir -p ~/.config/tmux
    # shall I move it elsewhere?
    DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
    ln -sf $DOTFILES_DIR/.config/tmux/tmux.conf ~/.config/tmux/tmux.conf

# ----------------------------------------------------------------------------
# Dotfiles

elif [ $task == "--dotfiles" ]; then
    set -x

    ok "Copies over all the dotfiles here to your home directory.
    - A backup will be made in $BACKUP_DIR
    - List of files that will be copied is in 'include.files'
    - Prompts again before actually running to make sure!"

    function create_dotfiles() {
        DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
        files=".aliases .bashrc .bash_profile .dircolors .export .functions .gitconfig .path git-prompt.sh"
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
        unset f
        unset files

        if [ ! -e "$HOME/.extra" ]; then
            echo "Copying: $DOTFILES_DIR/.extra --> $HOME/.extra"
            cp $DOTFILES_DIR/.extra $HOME/.extra
        fi
    }

    if [ $DOTFILES_FORCE == "true" ]; then
        create_dotfiles
    else
        read -p "This may overwrite existing files in your home directory. Backups will be put in $BACKUP_DIR. Are you sure? (y/n) " -n 1;
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            create_dotfiles
        fi
    fi
    unset doIt


# ----------------------------------------------------------------------------
# Diffs section

elif [ $task == "--diffs" ]; then
    command -v ~/opt/bin/icdiff >/dev/null 2>&1 || {
        printf "${RED}Can't find icdiff. Did you run ./setup.sh --install-icdiff?, and is ~/opt/bin on your \$PATH?${UNSET}\n"
            exit 1;
        }
    ok "Shows the diffs between this repo and what's in your home directory"
    cmd="$HOME/opt/bin/icdiff --recursive --line-numbers"
    $cmd ~ . | grep -v "Only in $HOME" | sed "s|$cmd||g"

elif [ $task == "--vim-diffs" ]; then
    ok "Opens up vim -d to display differences between files in this repo and your home directory"
    for i in $(git ls-tree -r HEAD --name-only | grep "^\."); do
        if ! diff $i ~/$i &> /dev/null; then
            nvim -d $i ~/$i;
        fi
    done
else
    showHelp

fi
