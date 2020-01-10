#!/bin.bash

# Based on:

# https://github.com/olemb/git-prompt
# Git prompt for Bash
# by Ole Martin Bjorndalen
# License: MIT



function git-prompt() {   
    local branch=''
 
    local oid=''
    local head=''

    local ahead=0
    local behind=0
    local untracked=0
    local conflict=0
    local changed=0

    # Are we on WSL or on Linux?
    # On WSL, calling git.exe is much faster
    local mnt_pattern='^/mnt/'
    if (grep -i -q microsoft /proc/version) && [[ $(pwd) =~ $mnt_pattern ]]; then
        local git_program='git.exe'
    else
        local git_program='git'
    fi

    # # Or use git only
    # GIT_PROGRAM='git'


    # Get data.

    # The 'local' statement needs to be on its own line since or it
    # will overwrite $?.

    # annoyingly windows git is much faster
    local status_text=''
    status_text=$($git_program status --porcelain=v2 --branch 2>/dev/null)
    if [ ! $? -eq 0 ]
    then
        # Not a Git repository (or some error occured).
        return
    fi

    # Parse data.
    local IFS=$'\n'
    for line in $status_text
    do
        if [[ $line =~ ^#[[:space:]]branch\.([a-z.]+)[[:space:]](.+)$ ]];
        then
            local name="${BASH_REMATCH[1]}"
            local value="${BASH_REMATCH[2]}"

            case $name in
                oid)
                    oid=$value
                    ;;
                head)
                    head=$value
                    ;;
                ab)
                    # change it here so we can remember and output number of ahead and behind
                    if [[ $line =~ \+[1-9] ]];
                    then
                        ahead=1
                    fi

                    if [[ $line =~ \-[1-9] ]];
                    then
                        behind=1
                    fi
                    ;;
            esac
        else
            case ${line:0:1} in
                \?)
                    ((untracked++))
                    ;;
                u)
                    ((conflict++))
                    ;;
                [1-2])
                    ((changed++))
                    ;;
            esac
        fi
    done

    # Get branch.
    if [ $oid == "(initial)" ]
    then
        branch=":initial"
    elif [ $head == "(detached)" ]
    then
        branch=":"${oid:0:6}
    else
        branch=$head
    fi

    # Add flags.
    local flags=
    local status="ok"

    if (( changed > 0 ))
    then
        # If this is '*' it will expand to filenames.
        flags=" *$changed"
        status="changed"
    fi

    if (( untracked > 0 ))
    then
        flags="$flags ?$untracked"
        status="untracked"
    fi

    if (( $ahead > 0 ))
    then
        flags="$flags >$ahead"
        status="different"
    fi

    if (( $behind > 0 ))
    then
        flags="$flags <$behind"
        status="different"
    fi

    if (( $conflict > 0 ))
    then
        flags="$flags !$conflict"
        status="conflict"
    fi

    local text="$branch$flags"


    # Add colors.

    case $status in
        ok)
            local colorcode="35"
            ;;
        changed | untracked | different)
            local colorcode="36"
            ;;
        conflict)
            local colorcode="31"
            ;;
    esac
    echo -ne "\e[0;${colorcode}m[${text}]\e[0m"
    # export GIT_STATUS="\e[0;${colorcode}m[${text}]\e[0m"
    # return "\e[0;${colorcode}m[${text}]\e[0m"
}


GIT_PROMPT_FETCH_LAST_TIME=0
GIT_PROMPT_FETCH_LAST_PWD=
GIT_PROMPT_FETCH_LAST_DIR=
GIT_PROMPT_FETCH_TIMEOUT=300


prompt_cmd () {
    
    # Are we on WSL or on Linux?
    # On WSL, calling git.exe is much faster
    local mnt_pattern='^/mnt/'
    if (grep -i -q microsoft /proc/version) && [[ $(pwd) =~ $mnt_pattern ]]; then
        local git_program='git.exe'
    else
        local git_program='git'
    fi

    # # Or use git only
    # GIT_PROGRAM='git'

    local git_status=$(git-prompt)

    if [ ! -z "$git_status" ]
    then
        # fetch on background -- actually, this is more tricky
        # I mean, ideally I would like to store it for a particular repo
        local fetch_pwd=$(pwd)
        local fetch_now=$(date +%s)
        local fetched=0
        if [ "$fetch_pwd" != "$GIT_PROMPT_FETCH_LAST_PWD" ]
        then
            # wsl is fast here
            GIT_PROMPT_FETCH_LAST_PWD=$ubuntufetch_pwd
            local fetch_dir=$(git rev-parse --show-toplevel)
            if [ "$fetch_dir" != "$GIT_PROMPT_FETCH_LAST_DIR" ]
            then
                GIT_PROMPT_FETCH_LAST_DIR=$fetch_dir
                fetched=1
                git_status="$git_status ..."
                GIT_PROMPT_FETCH_LAST_TIME=$fetch_now
                nohup $git_program fetch --quiet > /dev/null 2>&1 &
            fi 
        fi

        if (( fetched == 0 ))
        then
            if (( now > GIT_PROMPT_FETCH_LAST_TIME + GIT_PROMPT_FETCH_TIMEOUT ))
            then
                git_status="$git_status ..."
                GIT_PROMPT_FETCH_LAST_TIME=$fetch_now
                nohup $git_program fetch --quiet > /dev/null 2>&1 &
            fi
        fi
    fi

    # I need at least basic info about venv - do the usual
    if [ ! -z "$VIRTUAL_ENV" ]; then
        local venv_prompt="\e[0;37m[$(echo $VIRTUAL_ENV | sed 's/^.*[/\\]//')]\e[0m "
    else
        local venv_prompt=""
    fi

    PS1="\[\e]0;\w\a\]\n\[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\] ${git_status}\n${venv_prompt}\$ "
}






