# import git completion
export GIT_PS1_SHOWCOLORHINTS=true # Option for git-prompt.sh to show branch name in color
if [ -f ~/.git-completion.bash ]; then
        . ~/.git-completion.bash
fi

color_green="\[\033[0;32m\]"
color_cyan="\[\033[0;36m\]"
color_reset="\[\033[0m\]"

# Git functions
gb() {
        echo -n '[' && git branch 2>/dev/null | grep '^*' | colrm 1 2 | tr -d '\n' && echo  -n ']'
}
git_branch() {
        gb | sed 's/()//'
}

# Docker functions
docker_ps() {
        echo $(docker ps -q --no-trunc)
}
docker_container_ls() {
        echo $(docker container ls -aq --no-trunc)
}
docker_image_ls() {
        echo $(docker image ls -aq --no-trunc)
}
running_container_count() {
        docker_ps | wc -w
}
docker_container_count() {
        docker_container_ls | wc -w
}
docker_image_count() {
        docker_image_ls | wc -w
}
docker_print() {
        if [ $(running_container_count) -gt 0 ]; then
                docker inspect --format='       {{.Name}}' $(docker_ps) | cut -c2-
        fi
}
docker_nuke(){
        docker stop -f $(docker_ps)
        docker container rm -f $(docker_container_ls)
        docker image rm -f $(docker_image_ls)
        docker-compose down -v --rmi all --remove-orphans
}

STATUS='echo "";'
STATUS+='echo $(docker_image_count) images;'
STATUS+='echo $(docker_container_count) containers;'
STATUS+='echo $(running_container_count) running:;'
STATUS+='echo "$(docker_print)";'
STATUS+='echo ""; ls -lah; echo ""; git branch; git status;'
alias status=$STATUS

PS1="${color_green}\u${color_cyan} \w ${color_green}"
PS1+='$(git_branch)'
PS1+="\n└─ \$${color_reset} "
