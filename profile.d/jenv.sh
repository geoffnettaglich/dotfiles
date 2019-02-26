if which jenv > /dev/null; then 
  eval "$(jenv init -)"; 
  export PATH="$HOME/.jenv/bin:$PATH"
fi
