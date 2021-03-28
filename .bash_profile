# rvm
export LDFLAGS="-L/usr/local/opt/libffi/lib"

# nvm
export NVM_DIR=~/.nvm
source $(brew --prefix nvm)/nvm.sh

# golang
export GOPATH=/Users/$USER/Src/go
export PATH=$GOPATH/bin:$PATH

# Project specific vars
# --NONE--

# Load RVM into a shell session *as a function*
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

if [ -e /Users/d/.nix-profile/etc/profile.d/nix.sh ]; then . /Users/d/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer

# Colors
color_green="\[\033[0;32m\]"
color_cyan="\[\033[0;36m\]"
color_yellow="\[\033[0;33m\]"
color_reset="\[\033[0m\]"

# auto-completions
export GIT_PS1_SHOWCOLORHINTS=true # Option for git-prompt.sh to show branch name in color
completions=(git npm docker)
for i in "${completions[@]}"
do
	[ -e "/usr/local/etc/bash_completion.d/$i" ] && source "/usr/local/etc/bash_completion.d/$i"
done

# Prompt config
alias dir='ls -lah'

# iTerm tab titles (https://gist.github.com/phette23/5270658)
if [ $ITERM_SESSION_ID ]; then
  # export PROMPT_COMMAND='echo -ne "\033];${PWD##*/}\007"; ':"$PROMPT_COMMAND";
	export PROMPT_COMMAND="";
fi

STATUS='echo "";'
STATUS+='echo $(docker_image_count) images;'
STATUS+='echo $(docker_container_count) containers;'
STATUS+='echo $(running_container_count) running;'
# STATUS+='echo "$(docker_print)";'
STATUS+='echo ""; ls -lah; echo ""; git branch; git status;'
alias status=$STATUS

PS1="${color_green}\u${color_cyan} \w ${color_yellow}"
PS1+='$(package_name) '
PS1+="${color_green}"
PS1+='$(git_branch)'
PS1+="${color_green}"
PS1+="\n└─ \$${color_reset} "

package_name() {
	node -e 'try { console.log(require("./package.json").name) } catch (e) { console.log("_") }'
}

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
