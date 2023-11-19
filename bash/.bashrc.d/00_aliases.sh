# listing directories
alias ls='ls --color=auto -xX'
alias l='ls'
alias ll='ls -halF'
alias la='ls -A'
alias lh='ls -lisAd .[^.]*'

alias dir='dir --color=auto'
alias vdir='vdir --color=auto'

alias tree='tree -C'
alias tt='tree -haps'
alias td='tree -d'

# navigation
pushd () {
    if [[ $# -eq 0 ]]; then
        command pushd ~ > /dev/null || return 
    else
        command pushd $@ > /dev/null || return
    fi
}

popd () {
    command popd "$@" || return > /dev/null
}

alias cd='pushd'

alias ..='cd ..'
alias ....='cd ../..'
alias ......='cd ../../..'

# '--' signals end of flags
alias -- -='popd'
alias -- --='popd; popd'

# finding files
alias fn='find . -iname'
alias ff='find . -type f -iname'
alias fd='find . -type d -iname'

# grepping
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# processes
alias top="htop"
#alias ps="ps f"
alias pp="ps aux"
alias psg="ps aux | grep -v grep | grep -i -e VSZ -e"

# disk
alias df="df -Tha --total"
alias du="du -ach"

# memory
alias free="free -mt"

# misc
alias resource_bash="source ~/.bashrc"

alias wget="wget -c"

alias xo='xdg-open'
alias mkdir='mkdir -pv'

alias tgz='tar czvf'
alias untgz='tar xzvf'

alias clr='clear'
alias bl='tput bel'

alias busy='cat /dev/urandom | hexdump -C | grep "ca fe"'
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)"; tput bel'
