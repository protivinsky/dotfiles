#!/usr/bin/env bash
# Usage: is_vim.sh <tty>
#   tty: Specify tty to check for vim process.
tty=$1

ps -o state= -o comm= -t "$tty" |  grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf)(diff)?$'

# Check if the previous check succeeded, if not, construct the whole process tree
if [ $? -eq 0 ]; then
    exit 0
fi

# Construct process tree.
children=();
while read -r pid ppid; do
  [[ -n $pid && pid -ne ppid ]] && children[ppid]+=" $pid"
done <<< "$(ps -e -o pid= -o ppid=)"

# Get all descendant pids of processes in $tty with BFS
idx=0
IFS=$'\n' read -r -d '' -a pids < <(ps -o pid= -t $tty && printf '\0')
while (( ${#pids[@]} > idx )); do
  pid=${pids[idx++]}; pids+=( ${children[pid]-} )
done

# Check whether any child pids are vim
ps -o state= -o comm= -p "${pids[@]}" | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?)(diff)?$'
exit $?

