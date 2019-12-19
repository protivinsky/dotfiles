#!/bin/bash

# Source the user's bashrc if it exists - it will be executed only in interactive
if [ -f ~/.bashrc ] ; then
  source ~/.bashrc
fi

# Set PATH to includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi


# Set PATH to includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

