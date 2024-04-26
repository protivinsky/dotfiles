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

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"
export LANGUAGE="en_US.UTF-8"

export HISTSIZE='32768'
export HISTFILESIZE="${HISTSIZE}"
export HISTCONTROL='ignoreboth'

shopt -s histappend
PROMPT_COMMAND="history -a;$PROMPT_COMMAND"

# in tmux, highlight rather than italicize
export LESS_TERMCAP_so=$'\E[30;43m'
export LESS_TERMCAP_se=$'\E[39;49m'

export NNN_PLUG='f:finder;o:fzopen;p:preview-tui'

# set vim as manpager, with improved formatting
export MANROFFOPT="-c"
export MANPAGER="bash -c \"col -b | cat -s | nvim -c 'set ft=man ts=8 foldmethod=indent foldlevel=20 nomod nolist nonu noma'\""

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

# Interactive fuzzy find over history
bind '"\C-r": "\C-x1\e^\er"'
bind -x '"\C-x1": __fzf_history';

__fzf_history ()
{
__ehc $(history | fzf --tac --tiebreak=index | perl -ne 'm/^\s*([0-9]+)/ and print "!$1"')
}

__ehc()
{
if
        [[ -n $1 ]]
then
        bind '"\er": redraw-current-line'
        bind '"\e^": magic-space'
        READLINE_LINE=${READLINE_LINE:+${READLINE_LINE:0:READLINE_POINT}}${1}${READLINE_LINE:+${READLINE_LINE:READLINE_POINT}}
        READLINE_POINT=$(( READLINE_POINT + ${#1} ))
else
        bind '"\er":'
        bind '"\e^":'
fi
}

# do I want to keep this?
# https://github.com/JohanChane/ranger-quit_cd_wd
function ranger_wrapper {
    /usr/bin/env ranger $*
    local quit_cd_wd_file="$HOME/.cache/ranger/quit_cd_wd"
    if [ -s "$quit_cd_wd_file" ]; then
        cd "$(cat $quit_cd_wd_file)"
        true > "$quit_cd_wd_file"
    fi
}

alias ranger='ranger_wrapper'
alias r='ranger_wrapper'

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

alias c=clear
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

alias gsv="vim -c ':Git' -c ':bunload 1'"
alias glv="vim -c ':DiffviewFileHistory'"

mkcd()
{
  mkdir -p $1 && cd $1
}

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
