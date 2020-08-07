# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

export ZSH=$HOME/.oh-my-zsh

if [[ "$OSTYPE" == "linux-gnu" ]]; then
  # ...
  # Path to your oh-my-zsh installation.
  # export ZSH="/home/jonli/.oh-my-zsh"
  export ZSH=$HOME/.oh-my-zsh

  # wsl: git meld uses this temp folder so that meld on windosw can access files
  # export TMPDIR='/mnt/c/Users/rapto/AppData/Local/Temp'
elif [[ "$OSTYPE" == "darwin"* ]]; then
  # Mac OSX
  # Path to your oh-my-zsh installation.
  export ZSH="/Users/jonli/.oh-my-zsh"
elif [[ "$OSTYPE" == "cygwin" ]]; then
        # POSIX compatibility layer and Linux environment emulation for Windows
elif [[ "$OSTYPE" == "msys" ]]; then
  # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
  export ZSH=$HOME/.oh-my-zsh
elif [[ "$OSTYPE" == "win32" ]]; then
        # I'm not sure this can happen.
elif [[ "$OSTYPE" == "freebsd"* ]]; then
        # ...
else
        # Unknown.
fi

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
#ZSH_THEME="robbyrussell"
# ZSH_THEME="agnoster"
#ZSH_THEME="cobalt2"

ZSH_THEME="xxf"
HOST="[IDE] ($PROJECT_NAME)"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  git-flow
  node
  z
  brew
  tmux
  zsh-autosuggestions
  zsh-syntax-highlighting
)


# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
prompt_dir() {
  prompt_segment cyan black '%~'
}

unsetopt BG_NICE

function options() {
  PLUGIN_PATH="$HOME/.oh-my-zsh/plugins/"
  for plugin in $plugins; do
    echo "\n\nPlugin: $plugin"; grep -r "^function \w*" $PLUGIN_PATH$plugin | awk '{print $2}' | sed 's/()//'| tr '\n' ', '; grep -r "^alias" $PLUGIN_PATH$plugin | awk '{print $2}' | sed 's/=.*//' |  tr '\n' ', '
  done
}

# function git_prompt_info() {
  # ref=$(git symbolic-ref HEAD 2> /dev/null) || return
  # echo "$ZSH_THEME_GIT_PROMPT_PREFIX${ref#refs/heads/}$ZSH_THEME_GIT_PROMPT_SUFFIX"
# }

export PROMPT='${ret_status} %{$fg[cyan]%}%~%{$reset_color%} %{$fg[blue]%}$(git_current_branch)%{$reset_color%} $ '

# for nvm
# source ~/.bash_profile
#export NVM_DIR="$HOME/.nvm"
#[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
#[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


###-begin-pm2-completion-###
### credits to npm for the completion file model
#
# Installation: pm2 completion >> ~/.bashrc  (or ~/.zshrc)
#

COMP_WORDBREAKS=${COMP_WORDBREAKS/=/}
COMP_WORDBREAKS=${COMP_WORDBREAKS/@/}
export COMP_WORDBREAKS

if type complete &>/dev/null; then
  _pm2_completion () {
    local si="$IFS"
    IFS=$'\n' COMPREPLY=($(COMP_CWORD="$COMP_CWORD" \
                           COMP_LINE="$COMP_LINE" \
                           COMP_POINT="$COMP_POINT" \
                           pm2 completion -- "${COMP_WORDS[@]}" \
                           2>/dev/null)) || return $?
    IFS="$si"
  }
  complete -o default -F _pm2_completion pm2
elif type compctl &>/dev/null; then
  _pm2_completion () {
    local cword line point words si
    read -Ac words
    read -cn cword
    let cword-=1
    read -l line
    read -ln point
    si="$IFS"
    IFS=$'\n' reply=($(COMP_CWORD="$cword" \
                       COMP_LINE="$line" \
                       COMP_POINT="$point" \
                       pm2 completion -- "${words[@]}" \
                       2>/dev/null)) || return $?
    IFS="$si"
  }
  compctl -K _pm2_completion + -f + pm2
fi

source $ZSH/oh-my-zsh.sh

[[ -e ~/.profile ]] && emulate sh -c 'source ~/.profile'

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='rg --files --no-ignore-vcs --hidden'

# Load aliases if they exist.
[ -f "$HOME/.aliases" ] && source "$HOME/.aliases"

# Enable asdf to manage various programming runtime versions.
#   Requires: https://asdf-vm.com/#/
# source "$HOME"/.asdf/asdf.sh


# Helper functions
terraform() {
	docker run --rm -it -v ${HOST_PATH}/..$(pwd):/workspace -w /workspace hashicorp/terraform:light
}

# Aliases
# alias vim="nvim"
alias dive="docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock wagoodman/dive:latest $@"
alias sbt="docker run --rm -it -u $HOST_USER_ID:$HOST_GROUP_ID -v $HOST_PATH:/project -v $IVY_PATH:/tmp/.ivy2 -w /project ls12styler/scala-sbt:latest -Dsbt.ivy.home=/tmp/.ivy2 -Dsbt.global.base=/tmp/.sbt -Dsbt.boot.directory=/tmp/.sbt"
alias kubectl="docker run --rm -it -v ${KUBE_HOME}:/.kube -w /project -v ${HOST_PATH}:/project bitnami/kubectl:latest"
alias k8s=kubectl
alias helm="docker run -ti --rm -v ${HOST_PATH}:/apps -v ${KUBE_HOME}:/root/.kube -v ${KUBE_HOME}:/root/.config/kube -v ${HELM_HOME}:/root/.config/helm -v ${HELM_HOME}/cache:/root/.cache/helm alpine/helm"
alias gcloud="docker run --rm -it --volumes-from=gcloud-config -v ${HOST_PATH}:/local google/cloud-sdk:latest gcloud"
alias tf=terraform

#
# export http_proxy=http://web-proxy.xxxx.com:8080
# export https_proxy=http://web-proxy.xxxx.com:8080
#

