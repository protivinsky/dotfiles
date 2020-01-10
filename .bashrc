# ~/.bashrc: executed by bash(1) for non-login shells

# If not running interactively, don't do anything.
case $- in
    *i*) ;;
    *) return;;
esac


if [ -h ${BASH_SOURCE[0]} ]; then
    DOTFILES_DIR=$(dirname $(readlink ${BASH_SOURCE[0]}))
else 
    DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
fi

source $DOTFILES_DIR/git-prompt.sh
source $DOTFILES_DIR/load-colors.sh

# or do I want aliases in a separate file? maybe later
alias mc='mc --skin=darkfar'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ls='ls --color'
alias la='ls -a'
alias ll='ls -l'
alias c=clear
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# override diff2html if we are on wsl
if grep -i -q microsoft /proc/version; then
    alias diff2html='/mnt/c/Program\ Files/nodejs/node.exe C:\\Users\\thomas\\AppData\\Roaming\\npm\\node_modules\\diff2html-cli\\bin\\diff2html'
fi

load_colors --quiet terminal-sexy
clear

export LS_COLORS='ow=01;35;40'

# get rid of trailing white spaces or semicolons
PROMPT_COMMAND=$(echo "$PROMPT_COMMAND" | sed 's/[; \t]*$//')
ENTRIES_TO_PROMPT=("history -a" "prompt_cmd")
for NEW_ENTRY in "${ENTRIES_TO_PROMPT[@]}"; do
    if [[ -z "${PROMPT_COMMAND:+x}" ]]; then
        PROMPT_COMMAND=$NEW_ENTRY
    else
        case ";${PROMPT_COMMAND};" in
            *";${NEW_ENTRY};"*)
                :;;
            *)
                PROMPT_COMMAND="${PROMPT_COMMAND};${NEW_ENTRY}"
                ;;
        esac
    fi    
done

unset ENTRIES_TO_PROMPT
unset NEW_ENTRY

export PROMPT_COMMAND

export HISTSIZE=10000
export HISTFILESIZE=20000

stty -ixon

#alias python=python3

# if there is a local bashrc file, load it
if [ -f $HOME/.local/.bashrc ] && [ -r $HOME/.local/.bashrc ]; then
    source $HOME/.local/.bashrc
fi

# fix for tmux, to display colors correctly
# alias tmux="TERM=screen-256color-bce tmux"

