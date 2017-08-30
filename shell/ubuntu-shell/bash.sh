#!/bin/bash

#
# Using wget or curl command
#
# source <( curl --insecure         https://raw.githubusercontent.com/glennfriend/dotfiles/master/shell/ubuntu-shell/bash.sh )
# sh <(curl -L                      https://raw.githubusercontent.com/glennfriend/dotfiles/master/shell/ubuntu-shell/bash.sh )
# sh <(wget --no-check-certificate  https://raw.githubusercontent.com/glennfriend/dotfiles/master/shell/ubuntu-shell/bash.sh -O -)
# wget -q -O -                      https://raw.githubusercontent.com/glennfriend/dotfiles/master/shell/ubuntu-shell/bash.sh | sh
# bash < <(wget -O -                https://raw.githubusercontent.com/glennfriend/dotfiles/master/shell/ubuntu-shell/bash.sh )
# bash < <(curl -s                  https://raw.githubusercontent.com/glennfriend/dotfiles/master/shell/ubuntu-shell/bash.sh )
#
#


# history
export HISTTIMEFORMAT="%F %T: "

#
alias     ll='echo; last -n20; date "+%Y-%m-%d %H:%M:%S"; pwd; echo "----------"; l | grep "^l"; ls -d */; l | grep "^-";'
alias      l='ls -lhA --color'
alias     ld='ls */ -d'
alias     df='df -h'
alias        ..='cd ..'
alias       ...='cd ../..'
alias      ....='cd ../../..'
alias     .....='cd ../../../..'
alias    ......='cd ../../../../..'
alias    ..2='cd ../..'
alias    ..3='cd ../../..'
alias    ..4='cd ../../../..'
alias    ..5='cd ../../../../..'
alias    ..6='cd ../../../../../..'

# get ip
alias jip="curl icanhazip.com"
alias jlocalip="ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'"

# copy files
alias jcp="rsync -avv --stats --human-readable --itemize-changes --partial"

# --------------------------------------------------------------------------------
#   Functions
# --------------------------------------------------------------------------------

# reload .bashrc
jreloadbash() {
    source ~/.bashrc
}

# create folder
jmkdir() {
    mkdir -p -- "$1" &&
    cd -P -- "$1"
}

# now time
jdate() {
    echo "watch -t -n 1 date +%T"
    watch -t -n 1 date +%T
}

#
alias gow='cd /var/www; ls -lah;';

alias ch755='chmod -R 755 '
alias ch777='chmod -R 777 '
alias chwww='chown -R www-data:www-data '
alias chnobody='chown -R nobody:nogroup '


# crontab
export EDITOR=vim

# git
alias   gitlog='git log --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit -10 '
alias  gitlog2='git log --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit --graph -10 '
alias  gitlog3='git log --abbrev-commit --abbrev=4 --pretty=format:"%C(yellow)%h %C(green)[%cn] %C(cyan)%ar %C(bold magenta)%d %C(reset)%s" -10 '
alias       g2='clear; echo "---------- branch -av"; git branch -v; echo "---------- log"; gitlog -n 12; echo "---------- status"; git status -sb'
alias        g='clear; echo "---------- branch -av"; git branch -v; echo "---------- status"; git status -sb'
alias  gitdiff='git diff --color | diff-so-fancy'

function git_branch {
    ref=$(git symbolic-ref HEAD 2> /dev/null) || return;
    echo "("${ref#refs/heads/}") ";
}

function git_since_last_commit {
    now=`date +%s`;
    last_commit=$(git log --pretty=format:%at -1 2> /dev/null) || return;
    seconds_since_last_commit=$((now-last_commit));
    minutes_since_last_commit=$((seconds_since_last_commit/60));
    hours_since_last_commit=$((minutes_since_last_commit/60));
    minutes_since_last_commit=$((minutes_since_last_commit%60));

    echo "${hours_since_last_commit}h${minutes_since_last_commit}m ";
}




echo
echo "Completely"
echo



