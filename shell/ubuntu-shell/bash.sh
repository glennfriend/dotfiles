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

# --------------------------------------------------------------------------------
#   env
# --------------------------------------------------------------------------------

# history
export HISTTIMEFORMAT="%F %T: "

# crontab
export EDITOR=vim

# --------------------------------------------------------------------------------
#   custom
# --------------------------------------------------------------------------------
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
alias gow='cd /var/www      && ls -lah';
alias fs=' cd /fs           && ls -lah';
alias fsw='cd /fs/var/www   && ls -lah';
alias ch755='chmod -R 755 '
alias ch777='chmod -R 777 '
alias chwww='chown -R www-data:www-data '
alias chnobody='chown -R nobody:nogroup '

# cover
alias tail='tail -f '

# get ip
alias getip="curl icanhazip.com"
alias getlocalip="ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'"

# copy files
#   >f        傳輸文件
#   cd        建立目錄
#   st        檔案大小 & 時間 不同, 表示檔案內容有異動
#   +++++++++ 新增檔案
#
alias jcp="rsync -avv --stats --human-readable --itemize-changes --partial"

# --------------------------------------------------------------------------------
#   Custom Functions
# --------------------------------------------------------------------------------

# load my bash shell
jbash() {
    url="https://raw.githubusercontent.com/glennfriend/dotfiles/master/shell/ubuntu-shell/bash.sh"
    source <( curl --insecure {$url} )
}

# create folder
jmkdir() {
    mkdir -p -- "$1" &&
    cd -P -- "$1"
}

# now time
jdate() {
    # watch -t -n 1 date "+%Z\ [%z]\ %Y-%m-%d\ %T"
    while [ 1 ] ; do echo -en "  $(date +%Z\ [%z]\ %Y-%m-%d\ %T) \r" ; sleep 1; done
}

# 到數計時器
jsleep() {
    if [ -z "$1" ]
        then
            echo "No arguments supplied"
            return
    fi

    for ((i = $1; i >= 1; i--)); do
        timeFormat=$(date -u -d@$(($i)) +"%H:%M:%S")
        printf "\r%d <= %s " $i $timeFormat
        sleep 1
    done
    printf "\r"
    echo ""

}

#閱讀器 自動判斷
jread() {
    if [ -z "$1" ]
        then
            echo "No arguments supplied"
            return
    fi

    filename=$(basename "$1")
    ext="${filename##*.}"
    filename="${filename%.*}"

    #echo $filename
    #echo $ext

    if [ $ext == "md" ] ; then
        pandoc $1 | lynx -stdin
    elif [ $ext == "jpg" ] || [ $ext == "jpeg" ] || [ $ext == "gif" ] || [ $ext == "png" ] ; then
        file $1
    elif [ $ext == "php" ] || [ $ext == "js" ] || [ $ext == "css" ] ; then
        less -mN $1
    elif [ $ext == "conf" ] ; then
        less -mN $1
    else
        less -m $1
    fi
}

#
# 先備份, 後刪除
#
jrm() {

    left="\033[1;33m"
    right="\033[0m"

    absolute_path=$(readlink -m $1)
    echo ">"
    echo "> rm -rf $left$absolute_path$right"
    echo ">"


    if [ -z "$1" ] ; then
        echo "Input delete folder or files"
        return
    elif [ $1 == "." ] ; then
        echo "You must describe a directory"
        return
    elif [ $1 == ".." ] || [ $1 == "../" ]; then
        echo "You can not delete up floor directory"
        return
    fi

    now=$(date "+%m%d-%H%M%S")
    delete_folder="/tmp/delete/$now/"
    mkdir -p $delete_folder

    rsync -avv --human-readable --itemize-changes --partial $1 $delete_folder && rm -rf $1
    echo ""
    echo "rsync -avv --human-readable --itemize-changes --partial $1 $delete_folder && rm -rf $1"
    echo "ls -la $delete_folder"
    echo "----"
}

# --------------------------------------------------------------------------------
#   desktop
# --------------------------------------------------------------------------------
# alias ed='gedit'
alias   ed='/opt/sublime_text/sublime_text'

# --------------------------------------------------------------------------------
#   git
# --------------------------------------------------------------------------------

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



# --------------------------------------------------------------------------------
#   PHP, Laravel
# --------------------------------------------------------------------------------
alias cu="composer update"

alias testdox="php vendor/bin/phpunit --testdox"

alias art="php artisan"
alias migrate="php artisan migrate"
alias serve="artisan serve"
alias tinker="artisan tinker"
alias route-list="php artisan route:list"



# --------------------------------------------------------------------------------
#
# --------------------------------------------------------------------------------
echo
echo "Completely"
echo
