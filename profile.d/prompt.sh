# only bother if we are an interactive bash shell

# set -x

#echo "BASH VER: $BASH_VERSION"
#echo "PS1: $PS1"
#echo "INT: $-"

if [ -n "$BASH_VERSION" ] ; then

__setup_prompt() {
  local GRAY="\[\033[1;30m\]"
  local LIGHT_GRAY="\[\033[0;37m\]"
  local DARK_GRAY="\[\033[90m\]"
  local BLUE="\[\033[1;34m\]"
  local LBLUE="\[\033[94m\]"
  local LIGHT_BLUE="\[\033[0;34m\]"
  local CYAN="\[\033[0;36m\]"
  local LIGHT_CYAN="\[\033[1;36m\]"
  local NO_COLOUR="\[\033[0m\]"
  local RED="\[\033[1;31m\]"
  local LIGHT_RED="\[\033[0;31m\]"
  local GREEN="\[\033[1;32m\]"
  local LIGHT_GREEN="\[\033[92m\]"
  local YELLOW="\[\033[0;33m\]"
  local LIGHT_YELLOW="\[\033[93m\]"
  local BLUE256="\[\033[38;5;33m\]"

  local TYPE_SSH="remote/ssh"

  if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    SESSION_TYPE=${TYPE_SSH}
    # many other tests omitted
  else
    case $(ps -o comm= -p "$PPID") in
      sshd|*/sshd) SESSION_TYPE=${TYPE_SSH};;
    esac
  fi

  case $TERM in
    xterm*|rxvt*|linux*)
      local TITLEBAR='\[\033]0;\u@\h:\w\007\]'
      ;;
    *)
      local TITLEBAR=""
      ;;
  esac

  if [ ${UID} -eq 0 ] ; then
    TEXT="$RED"
  elif [ "$OS" == "Darwin" ] ; then
    TEXT="$CYAN"
  else
    TEXT="$BLUE"
  fi

  BRDR="$LIGHT_GRAY"

  local temp=$(tty)
  local GRAD1=${temp:5}

  PS_TERM="::"

  if [ "$SESSION_TYPE" = "$TYPE_SSH" ] ; then
    PS_TERM=":: $LIGHT_RED(ssh)$NO_COLOUR ::"
    PS_TERM=":: $YELLOW(ssh)$NO_COLOUR ::"
  fi

  PS_TOP="$TITLEBAR\n$BRDR[ $DARK_GRAY\d \t$BRDR ] $PS_TERM [ $TEXT\w$BRDR ]"
  PS_SIDE=" $BRDR\n[ $TEXT\u$BRDR@$TEXT\h $BRDR]\$ $NO_COLOUR"
  PS1="$PS_TOP $PS_SIDE"
  PS2="$LIGHT_CYAN-$CYAN-$GRAY-$NO_COLOUR "

  if [[ "function" == `type -t __git_ps1` ]] ; then
    PROMPT_COMMAND="__git_ps1 '$PS_TOP' '$PS_SIDE' "
  fi
}

__setup_prompt

fi
