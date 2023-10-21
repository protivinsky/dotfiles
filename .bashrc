# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{path,exports,bash_prompt,functions,aliases,extra}; do
    [ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

[ -z "$PS1" ] && return             # exit early if not interactive
shopt -s checkwinsize               # updates size of terminal after commands

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
    shopt -s "$option" 2> /dev/null || true
done;

if [ -f /etc/bash_completion ]; then
    source /etc/bash_completion;
fi

# makes less work on things like tarballs and images
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# enable color support of ls and also add handy aliases
if [ `command -v dircolors` ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

VIRTUAL_ENV_DISABLE_PROMPT=1

function venv-prompt() {
    if [ ! -z "$VIRTUAL_ENV" ]; then
        echo -ne "\e[37m[$(echo $VIRTUAL_ENV | sed 's|.*/\(.*\)/\(.*\)|\1/\2|')]\e[0m "
    fi
}

source $HOME/git-prompt.sh

PS1="\[\e]0;\w\a\]\n\[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\] \$(git-prompt)\n\$(venv-prompt)\$ "

