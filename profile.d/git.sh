
BREW=`which brew`

if [ ! -z "$BREW" ] ; then
  PREFIX=`brew --prefix`
  GIT_PREFIX=`brew --prefix git`
fi

if [ -n "$PS1" -a -f "$PREFIX/etc/bash_completion.d/git-completion.bash" ]; then
  echo "Git completion"
  . $PREFIX/etc/bash_completion.d/git-completion.bash
fi

if [ -f "$GIT_PREFIX/etc/bash_completion.d/git-prompt.sh" ]; then
  echo "Git prompt"
  . $GIT_PREFIX/etc/bash_completion.d/git-prompt.sh
fi

# reset prompt so git prompt can kick in
GIT_PS_EXISTS=`type -t __git_ps1`

if [ "function" == "$GIT_PS_EXISTS" ] ; then
  echo "  Git func exists, setting variables ..."
  GIT_PS1_SHOWDIRTYSTATE=true
  GIT_PS1_SHOWCOLORHINTS=true
  GIT_PS1_UNTRACKEDFILES=true
  GIT_PS1_SHOWUNTRACKEDFILES=true

  # some magic if we use our own PS_* sections (ie. some other prompt setup may have set it)
  if [ -z "$PS_TOP" -a -z "$PS_SIDE" ] ; then
    PROMPT_COMMAND='__git_ps1 "\u@\h:\w" "\\\$ "; $PROMPT_COMMAND'
  else
    PROMPT_COMMAND="__git_ps1 '$PS_TOP' '$PS_SIDE'; $PROMPT_COMMAND"
  fi
fi
