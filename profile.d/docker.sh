#!/bin/sh
#
# See https://gist.github.com/cjus/20c2e1026524e83db532b113dce02403
#
alias dk='docker'
alias dki='docker images'
alias dks='docker service'
alias dkrm='docker rm'
alias dkl='docker logs'
alias dklf='docker logs -f'
alias dkflush='docker rm `docker ps --no-trunc -aq`'
alias dkflush2='docker rmi $(docker images --filter "dangling=true" -q --no-trunc)'
alias dkt='docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"'
alias dkps="docker ps --format '{{.ID}} ~ {{.Names}} ~ {{.Status}} ~ {{.Image}}'"

dkln() {
  docker logs -f `docker ps | grep $1 | awk '{print $1}'`
}

dkpl() {
  if [ ! -f .dockerignore ]; then
    echo "Warning, .dockerignore file is missing."
    read -p "Proceed anyway?"
  fi

  if [ ! -f package.json ]; then
    echo "Warning, package.json file is missing."
    read -p "Are you in the right directory?"
  fi

  VERSION=`cat package.json | jq .version | sed 's/\"//g'`
  NAME=`cat package.json | jq .name | sed 's/\"//g'`
  LATEST="$1/$NAME:latest"

  docker build --build-arg NPM_TOKEN=${NPM_TOKEN} --no-cache=true -t $LATEST .
  read -p "Press enter to publish"
  docker push $LATEST
}

dkclean() {
  docker rm $(docker ps --all -q -f status=exited)
  docker volume rm $(docker volume ls -qf dangling=true)
}

dkprune() {
  docker system prune -af
}

dktop() {
  docker stats --format "table {{.Container}}\t{{.Name}}\t{{.CPUPerc}}  {{.MemPerc}}\t{{.NetIO}}\t{{.BlockIO}}"
}

dkstats() {
  if [ $# -eq 0 ]
    then docker stats --no-stream;
    else docker stats --no-stream | grep $1;
  fi
}

dke() {
  docker exec -it $1 /bin/sh
}

dkexe() {
  docker exec -it $1 $2
}

dkreboot() {
  osascript -e 'quit app "Docker"'
  countdown 2
  open -a Docker
  echo "Restarting Docker engine"
  countdown 120
}

dkstate() {
  docker inspect $1 | jq .[0].State
}

mongo() {
  mongoLabel=`docker ps | grep mongo | awk '{print $NF}'`
  docker exec -it $mongoLabel mongo "$@"
}

redis() {
  redisLabel=`docker ps | grep redis | awk '{print $NF}'`
  docker exec -it $redisLabel redis-cli
}
