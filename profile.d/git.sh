if [ -n "$PS1" -a -f `brew --prefix`/etc/bash_completion.d/git-completion.bash ]; then
  echo "Git completion"
  . `brew --prefix`/etc/bash_completion.d/git-completion.bash
fi
 
if [ -f `brew --prefix git`/etc/bash_completion.d/git-prompt.sh ]; then
  echo "Git prompt"
  . `brew --prefix git`/etc/bash_completion.d/git-prompt.sh
  # reset prompt so git prompt can kick in
  GIT_PS1_SHOWDIRTYSTATE=true
  GIT_PS1_SHOWCOLORHINTS=true
  GIT_PS1_UNTRACKEDFILES=true
  GIT_PS1_SHOWUNTRACKEDFILES=true
  # PROMPT_COMMAND="prompt"
  PROMPT_COMMAND="__git_ps1 '$PS_TOP' '$PS_SIDE'"
fi
