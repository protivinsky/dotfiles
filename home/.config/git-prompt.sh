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

    # Get data.
    # The 'local' statement needs to be on its own line since or it
    # will overwrite $?.

    local status_text=''
    status_text=$(git status --porcelain=v2 --branch 2>/dev/null)
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
    if [ $oid == "(initial)" ]; then
        branch=":initial"
    elif [ $head == "(detached)" ]; then
        branch=":"${oid:0:6}
    else
        branch=$head
    fi

    # Add flags.
    local flags=
    local status="ok"

    if (( changed > 0 )); then
        # If this is '*' it will expand to filenames.
        flags=" *$changed"
        status="changed"
    fi

    if (( untracked > 0 )); then
        flags="$flags ?$untracked"
        status="untracked"
    fi

    if (( $ahead > 0 )); then
        flags="$flags >$ahead"
        status="different"
    fi

    if (( $behind > 0 )); then
        flags="$flags <$behind"
        status="different"
    fi

    if (( $conflict > 0 )); then
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
}

