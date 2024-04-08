#!/bin/bash
# Heavily inspired by https://github.com/daler/dotfiles

GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
BLUE="\e[34m"
UNSET="\e[0m"

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

export PS1=

# VERSIONS
NVIM_VERSION=0.9.5

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
	url=$1
	dest=$2
	command -v curl >/dev/null && curl -fL $url >$dest
}
try_wget() {
	url=$1
	dest=$2
	command -v wget >/dev/null && wget -O- $url >$dest
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
add_line_to_file() {
	line=$1
	file=$2
	if [ ! -e "$file" ]; then
		echo "$line" >>$file
	elif grep -vq "$line" $file; then
		echo "$line" >>$file
	fi
}

# Prompt user for info ($1 is text to provide)
ok() {
	# If the DOTFILES_FORCE=true env var was set, then no need to ask, we want
	# to always say yes
	if [[ -v DOTFILES_FORCE && $DOTFILES_FORCE -eq 1 ]]; then
		return 0
	fi
	printf "${GREEN}$1${UNSET}\n"
	read -p "Continue? (y/[n]) " -n 1 REPLY
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
        ln -sf $DOTFILES_DIR/home/.config/tmux/is_vim_fixed.sh $HOME/.config/tmux/is_vim_fixed.sh
        mkdir -p $HOME/.tmux/plugins
        clone_if_not_exists https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
        $HOME/.tmux/plugins/tpm/bin/install_plugins
}

function install_neovim() {
	ok "Downloads neovim tarball from https://github.com/neovim/neovim, install into $LOCAL_OPT/neovim and create symlink $LOCAL_BIN/nvim"
	printf "${YELLOW}Installing neovim${UNSET}\n"
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

	# install my version of lazyvim starter
	# clone_if_not_exists http://github.com/nvim-lua/kickstart.nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim
	clone_if_not_exists https://github.com/protivinsky/lazyvim-starter.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim
	source $HOME/.bashrc
}

function install_python() {
	ok "Installing python3 and python3-venv and create symlink $LOCAL_BIN/python"
	sudo apt-get install -y python3 python3-venv python3-pip
	printf "${YELLOW}- installed python3 and python3-venv ${UNSET}\n"
	ln -sf $(which python3) $LOCAL_BIN/python
	printf "${YELLOW}- created symlink $LOCAL_BIN/python${UNSET}\n"
}

# function install_node() {
# 	ok "Installing nodejs and npm via nvm"
# 	wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
# 	export NVM_DIR="$HOME/.nvm"
# 	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
# 	[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
# 	nvm install node
# 	printf "${GREEN}nodejs and npm installed.${UNSET}\n"
# }

function install_lazygit() {
	LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
	curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
	tar xf lazygit.tar.gz lazygit
	sudo install lazygit $LOCAL_BIN
	rm lazygit.tar.gz lazygit
}

# function install_lunarvim() {
# 	if ! command -v nvim >/dev/null 2>&1; then
# 		install_neovim
# 	fi
# 	LV_BRANCH='release-1.3/neovim-0.9' bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.3/neovim-0.9/utils/installer/install.sh)
# }
#
# function install_nvchad() {
# 	if ! command -v nvim >/dev/null 2>&1; then
# 		install_neovim
# 	fi
# 	if [ ! -d $XDG_CONFIG_HOME/nvchad ]; then
# 		git clone https://github.com/NvChad/NvChad $XDG_CONFIG_HOME/nvchad --depth 1
# 	fi
#
# 	add_line_to_file "alias nvchad='NVIM_APPNAME=nvchad nvim'" $HOME/.local/.bashrc
# }

# function install_lazyvim() {
# 	if ! command -v nvim >/dev/null 2>&1; then
# 		install_neovim
# 	fi
# 	if [ ! -d $XDG_CONFIG_HOME/lazyvim ]; then
# 		git clone https://github.com/LazyVim/starter $XDG_CONFIG_HOME/lazyvim
# 		rm -rf $XDG_CONFIG_HOME/lazyvim/.git
# 	fi
#
# 	add_line_to_file "alias lazyvim='NVIM_APPNAME=lazyvim nvim'" $HOME/.local/.bashrc
# }

# function install_astrovim() {
# 	if ! command -v nvim >/dev/null 2>&1; then
# 		install_neovim
# 	fi
# 	if [ ! -d $XDG_CONFIG_HOME/astrovim ]; then
# 		git clone --depth 1 https://github.com/AstroNvim/AstroNvim $XDG_CONFIG_HOME/astrovim
# 	fi
#
# 	add_line_to_file "alias astrovim='NVIM_APPNAME=astrovim nvim'" $HOME/.local/.bashrc
# }

function install_apt() {
	ok "Installing additional packages"
	sudo apt-get install -y build-essential wget curl htop rsync stow ripgrep fd-find
	sudo apt-get install -y fzf linux-libc-dev gcc libc6-dev make cargo
	sudo apt-get install -y libtool-bin autoconf automake cmake doxygen
}

while [[ "$#" -gt 0 ]]; do
	case $1 in
	-y | --yes)
		DOTFILES_FORCE=true
		shift
		;;
	--dotfiles)
		copy_dotfiles
		shift
		;;
 
	--nvim | --neovim)
		install_neovim
		shift
		;;
	--python)
		install_python
		shift
		;;
	--lazygit)
		install_lazygit
		shift
		;;
	--apt)
		install_apt
		shift
		;;
	--all)
		copy_dotfiles
		install_apt
		if ! command -v tmux >/dev/null 2>&1; then
			install_tmux
		fi
		install_python
		if ! command -v lazygit >/dev/null 2>&1; then
			install_lazygit
		fi
		if ! command -v nvim >/dev/null 2>&1; then
			install_neovim
		fi
		# if ! command -v node >/dev/null 2>&1; then
		# 	install_node
		# fi
		exit 1
		;;
	*)
		echo "Unknown option: $1"
		exit 1
		;;
	esac
done

printf "${GREEN}Dotfiles installation is complete.${UNSET}\n"

# source $HOME/.bashrc
