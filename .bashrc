# To the extent possible under law, the author(s) have dedicated all 
# copyright and related and neighboring rights to this software to the 
# public domain worldwide. This software is distributed without any warranty. 
# You should have received a copy of the CC0 Public Domain Dedication along 
# with this software. 
# If not, see <http://creativecommons.org/publicdomain/zero/1.0/>. 

# PS1="\[\e]0;\w\a\]\n\[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\] \$(git-prompt)\n\$ "
# PS1='\[\e]0;\w\a\]\n\[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\]\n\$ '
# PS1="\[\e]0;\w\a\]\n\[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\] ${GIT_STATUS}\n\$ "

# NOT BAD -- ONLY TOO HEAVY
# https://github.com/magicmonty/bash-git-prompt
# if [ -f "$HOME/.bash-git-prompt/gitprompt.sh" ]; then
#     GIT_PROMPT_ONLY_IN_REPO=1
#     source $HOME/.bash-git-prompt/gitprompt.sh
# fi

if [ -h ${BASH_SOURCE[0]} ]; then
    DOTFILES_DIR=$(dirname $(readlink ${BASH_SOURCE[0]}))
else 
    DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
fi

echo "DOTFILES_DIR = $DOTFILES_DIR"

source $DOTFILES_DIR/git-prompt.sh
source $DOTFILES_DIR/load-colors.sh

# or do I want aliases in a separate file? maybe later
alias mc='mc --skin=darkfar'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ls="ls --color"

# I need to fix diff2html -- as I cannot send the file to browser easily
diff2html() {
    # I should check that --file is not in parameters...
    diff2html --file=/mnt/d/temp/diff.html $@
    # /mnt/c/Program\ Files/Opera/launcher.exe file:///D:/temp/diff.html
}


load_colors terminal-sexy

clear
#cd ~

export LS_COLORS='ow=01;36;40'

ENTRIES_TO_PROMPT=("history -a" "prompt_cmd")
for NEW_ENTRY in "${ENTRIES_TO_PROMPT[@]}"; do
    if [[ -z "${PROMPT_COMMAND:+x}" ]]; then
        PROMPT_COMMAND=$NEW_ENTRY
    else
        case ";${PROMPT_COMMAND};" in
            *";${NEW_ENTRY};"*)
                # echo "PROMPT_COMMAND already contains: $new_entry"
                :;;
            *)
                PROMPT_COMMAND="${PROMPT_COMMAND};${NEW_ENTRY}"
                # echo "PROMPT_COMMAND does not contain: $new_entry"
                ;;
        esac
    fi
done

unset ENTRIES_TO_PROMPT
unset NEW_ENTRY

export PROMPT_COMMAND

export HISTSIZE=10000
export HISTFILESIZE=20000


#alias python=python3

# should I add some conditioning if I am on wsl or cygwin?
export SPARK_HOME=/opt/spark
export HADOOP_HOME=/opt/spark
export HADOOP_CONF_DIR=/etc/hadoop/conf
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64/jre
export PATH=/opt/spark/bin:$PATH

# # if there is a local bashrc file, load it
# if [ -f $HOME/.bashrc.local ] && [ -r $HOME/.bashrc.local ]; then
#     source $HOME/.bashrc.local
# fi

# figure out how to display it somewhere more hidden (message on the right of the prompt?)
echo ".bashrc executed."

# fix for tmux, to display colors correctly
# alias tmux="TERM=screen-256color-bce tmux"

