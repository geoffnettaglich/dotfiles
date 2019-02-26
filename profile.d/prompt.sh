# only bother if we are an interactive bash shell

#echo "BASH VER: $BASH_VERSION"
#echo "PS1: $PS1"
#echo "INT: $-"

if [ -n "$BASH_VERSION" ] ; then

__setup_prompt() {
  local GRAY="\[\033[1;30m\]"
  local LIGHT_GRAY="\[\033[0;37m\]"
  local BLUE="\[\033[1;34m\]"
  local LIGHT_BLUE="\[\033[0;34m\]"
  local CYAN="\[\033[0;36m\]"
  local LIGHT_CYAN="\[\033[1;36m\]"
  local NO_COLOUR="\[\033[0m\]"
  local RED="\[\033[1;31m\]"
  local GREEN="\[\033[1;32m\]"
  local BLUE256="\[\033[38;5;33m\]"

  case $TERM in
    xterm*|rxvt*|linux*)
      local TITLEBAR='\[\033]0;\u@\h:\w\007\]'
      ;;
    *)
      local TITLEBAR=""
      ;;
  esac

  if [ ${UID} -eq 0 ]; then
    TEXT="$RED"
  else
    TEXT="$CYAN"
  fi

  BRDR="$LIGHT_GRAY"

  local temp=$(tty)
  local GRAD1=${temp:5}

  PS_TOP="$TITLEBAR\n$BRDR[ $TEXT\d \t $BRDR] :: [ $TEXT\w$BRDR ]"
  PS_SIDE=" $BRDR\n[ $TEXT\u$BRDR@$TEXT\h $BRDR]\$ $NO_COLOUR"
  PS1="$PS_TOP $PS_SIDE"
  PS2="$LIGHT_CYAN-$CYAN-$GRAY-$NO_COLOUR "
  PROMPT_COMMAND="__git_ps1 '$PS_TOP' '$PS_SIDE' "
}

__setup_prompt

fi
