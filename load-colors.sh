#!/bin/sh

# Script is loosely based on:
# 
# base16-shell (https://github.com/chriskempson/base16-shell)
# Base16 Shell template by Chris Kempson (http://chriskempson.com)


# list all colors in colors subdirectory
list_colors() {
    local DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
    ls $DOTFILES_DIR/colors/ | grep -v colortest.sh | sed s/\.sh//
}
  

test_colors() {
    local DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
    source $DOTFILES_DIR/colors/colortest.sh
}


# load a given color scheme
load_colors () {

    if [ "$1" == "--quiet" ]; then
        TEST_COLORS=false
        shift
    else
        TEST_COLORS=true
    fi

    DOTFILES_COLOR_SCHEME=$1

    # check parameter and complain if not provided.
    local DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
    source "$DOTFILES_DIR/colors/$1.sh"

    if [ -n "$TMUX" ]; then
        # Tell tmux to pass the escape sequences through
        # (Source: http://permalink.gmane.org/gmane.comp.terminal-emulators.tmux.user/1324)
        put_template() { printf '\033Ptmux;\033\033]4;%d;rgb:%s\033\033\\\033\\' $@; }
        put_template_var() { printf '\033Ptmux;\033\033]%d;rgb:%s\033\033\\\033\\' $@; }
        put_template_custom() { printf '\033Ptmux;\033\033]%s%s\033\033\\\033\\' $@; }
    elif [ "${TERM%%[-.]*}" = "screen" ]; then
        # GNU screen (screen, screen-256color, screen-256color-bce)
        put_template() { printf '\033P\033]4;%d;rgb:%s\007\033\\' $@; }
        put_template_var() { printf '\033P\033]%d;rgb:%s\007\033\\' $@; }
        put_template_custom() { printf '\033P\033]%s%s\007\033\\' $@; }
    elif [ "${TERM%%-*}" = "linux" ]; then
        put_template() { [ $1 -lt 16 ] && printf "\e]P%x%s" $1 $(echo $2 | sed 's/\///g'); }
        put_template_var() { true; }
        put_template_custom() { true; }
    else
        put_template() { printf '\033]4;%d;rgb:%s\033\\' $@; }
        put_template_var() { printf '\033]%d;rgb:%s\033\\' $@; }
        put_template_custom() { printf '\033]%s%s\033\\' $@; }
    fi

    # 16 color space
    put_template 0  $color00
    put_template 1  $color01
    put_template 2  $color02
    put_template 3  $color03
    put_template 4  $color04
    put_template 5  $color05
    put_template 6  $color06
    put_template 7  $color07
    put_template 8  $color08
    put_template 9  $color09
    put_template 10 $color10
    put_template 11 $color11
    put_template 12 $color12
    put_template 13 $color13
    put_template 14 $color14
    put_template 15 $color15

    # foreground / background / cursor color
    put_template_var 10 $color_foreground
    if [ "$BASE16_SHELL_SET_BACKGROUND" != false ]; then
        put_template_var 11 $color_background
        if [ "${TERM%%-*}" = "rxvt" ]; then
            put_template_var 708 $color_background # internal border (rxvt)
        fi
    fi
    put_template_custom 12 ";7" # cursor (reverse video)

    # clean up
    unset -f put_template
    unset -f put_template_var
    unset -f put_template_custom
    unset color00
    unset color01
    unset color02
    unset color03
    unset color04
    unset color05
    unset color06
    unset color07
    unset color08
    unset color09
    unset color10
    unset color11
    unset color12
    unset color13
    unset color14
    unset color15
    unset color_foreground
    unset color_background

  
    if $TEST_COLORS; then
        echo "Loaded colors $1."
        source $DOTFILES_DIR/colors/colortest.sh
    fi

}
