#!/bin/bash

# ==============
# ===  PATH  ===

# Set PATH to includes user's private bin if it exists
for dir in $HOME/bin $HOME/.local/bin; do
	if [ -d "$dir" ]; then
		export PATH="$dir:$PATH"
	fi
done
unset dir

# =================
# ===  EXPORTS  ===

if command -v nvim >/dev/null; then
	export EDITOR="nvim"
else
	export EDITOR="vim"
fi

export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"
export LANGUAGE="en_US.UTF-8"

export HISTSIZE='32768'
export HISTFILESIZE="${HISTSIZE}"
export HISTCONTROL='ignoreboth'

# in tmux, highlight rather than italicize
export LESS_TERMCAP_so=$'\E[30;43m'
export LESS_TERMCAP_se=$'\E[39;49m'

# set vim as manpager, with improved formatting
export MANPAGER="bash -c \"col -b | cat -s | vim -c 'set ft=man ts=8 foldmethod=indent foldlevel=20 nomod nolist nonu noma' - --not-a-term\""

# =================
# ===  ALIASES  ===

alias grep='grep --color=auto'
alias ls='ls --color=auto'

# Vanilla MacOS has a different `ls` for which we use -G instead of --color.
# However if you've conda-installed coreutils, that `ls` will be used.
# So the following sets the color differently if we're on Mac and not using
# coreutils from conda.
if [[ $OSTYPE == darwin* ]]; then
	if [[ $(which ls) == "/usr/bin/ls" ]] || [[ $(which ls) == "/bin/ls" ]]; then
		alias ls='ls -G'
	fi
fi

alias ll='ls -lrth'
alias la='ls -lrthA'
alias l='ls -CF'
alias tmux="tmux -u"

# Sometimes when you try to open an X window, especially running tmux, you can
# get an error about the display variable not being set. This alias fixes that.
alias D="export DISPLAY=:0"

# View syntax-highlighted files in the current directory, live-filtered by fzf.
alias v='fzf --preview "bat --color \"always\" {}"'

if command -v nvim >/dev/null; then
	alias vim=nvim
fi

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

alias c=clear
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

alias mc='mc --skin=gotar'

alias gsv="vim -c ':Git' -c ':bunload 1'"
alias glv="vim -c ':DiffviewFileHistory'"

# if there is a local bashrc file, load it
if [ -f $HOME/.local/.bashrc ] && [ -r $HOME/.local/.bashrc ]; then
	source $HOME/.local/.bashrc
fi

# ====================
# ===  PROMPT ETC  ===

[ -z "$PS1" ] && return # exit early if not interactive
shopt -s checkwinsize   # updates size of terminal after commands

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
	shopt -s "$option" 2>/dev/null || true
done

if [ -f /etc/bash_completion ]; then
	source /etc/bash_completion
fi

# makes less work on things like tarballs and images
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# enable color support of ls and also add handy aliases
if [ $(command -v dircolors) ]; then
	test -r ~/.config/.dircolors && eval "$(dircolors -b ~/.config/.dircolors)" || eval "$(dircolors -b)"
fi

VIRTUAL_ENV_DISABLE_PROMPT=1

function venv-prompt() {
	if [ ! -z "$VIRTUAL_ENV" ]; then
		echo -ne "[$(echo $VIRTUAL_ENV | sed 's|.*/\(.*\)/\(.*\)|\1/\2|')] "
	fi
}

source $HOME/.config/git-prompt.sh

PS1="\[\e[37m\]\u@\h \[\e[33m\]\w\[\e[0m\] \$(git-prompt)\n\[\e[37m\]\$(venv-prompt)\[\e[0m\]\$ "

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
. "$HOME/.cargo/env"
alias lazyvim='NVIM_APPNAME=lazyvim nvim'

# alias nvim-lazy="NVIM_APPNAME=LazyVim nvim"
# alias nvim-kick="NVIM_APPNAME=kickstart nvim"
# alias nvim-chad="NVIM_APPNAME=NvChad nvim"
# alias nvim-astro="NVIM_APPNAME=AstroNvim nvim"
#
# function nvims() {
#   items=("default" "kickstart" "LazyVim" "NvChad" "AstroNvim")
#   config=$(printf "%s\n" "${items[@]}" | fzf --prompt=" Neovim Config  " --height=~50% --layout=reverse --border --exit-0)
#   if [[ -z $config ]]; then
#     echo "Nothing selected"
#     return 0
#   elif [[ $config == "default" ]]; then
#     config=""
#   fi
#   NVIM_APPNAME=$config nvim $@
# }
