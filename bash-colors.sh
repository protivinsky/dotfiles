#!/bin/sh
# base16-shell (https://github.com/chriskempson/base16-shell)
# Base16 Shell template by Chris Kempson (http://chriskempson.com)
# Classic Dark scheme by Jason Heeris (http://heeris.id.au)


color00="28/2a/2e"
color01="a5/42/42"
color02="8c/94/40"
color03="de/93/5f"
color04="5f/81/9d"
color05="85/67/8f"
color06="5e/8d/87"
color07="70/78/80"
color08="37/3b/41"
color09="cc/66/66"
color10="b5/bd/68"
color11="f0/c6/74"
color12="81/a2/be"
color13="b2/94/bb"
color14="8a/be/b7"
color15="c5/c8/c6"
color_background="1d/1f/21"
color_foreground="c5/c8/c6"

# #color00="31/3f/46"
# #color00="1f/1f/1f"
# color00="2b/29/1a"
# color00="22/22/22"
# color01="c3/16/33"
# color02="4c/af/50"
# color03="ef/aa/04"
# color04="09/61/c4"
# color05="8a/0c/8f"
# color06="06/7d/8a"
# color07="b0/be/c6"
# color08="4a/58/60"
# color09="ff/56/73"
# color10="8c/ef/90"
# color11="ff/ea/44"
# color12="49/a1/ff"
# color13="ca/4c/cf"
# color14="46/bd/ca"
# color15="f2/fb/ff"
# color_background=$color00 # Base 00
# #color_background="1f/1f/1f" # Base 00
# #color_background="31/3f/46"
# color_foreground="f2/fb/ff"
# color18="f2/fb/ff"


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
