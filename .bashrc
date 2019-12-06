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

source ~/.dotfiles/git-prompt.sh
source ~/.dotfiles/load-colors.sh

clear
#cd ~

export LS_COLORS='ow=01;36;40'
export PROMPT_COMMAND="history -a; prompt_cmd; $PROMPT_COMMAND"
export HISTSIZE=10000
export HISTFILESIZE=20000

alias ls="ls --color"

#alias python=python3

# should I add some conditioning if I am on wsl or cygwin?
export SPARK_HOME=/opt/spark
export HADOOP_HOME=/opt/spark
export HADOOP_CONF_DIR=/etc/hadoop/conf
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64/jre
export PATH=/opt/spark/bin:$PATH

# figure out how to display it somewhere more hidden (message on the right of the prompt?)
echo ".bashrc executed."

# fix for tmux, to display colors correctly
# alias tmux="TERM=screen-256color-bce tmux"

