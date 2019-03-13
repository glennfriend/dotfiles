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
export VISUAL=vim

# --------------------------------------------------------------------------------
#   custom
# --------------------------------------------------------------------------------
#
alias     ll='echo; last -n20; echo "----------"; echo "timezone : "`cat /etc/timezone`; echo "boot-time: "`uptime -s`; echo "now      : "`date "+%Y-%m-%d %H:%M:%S"`; echo "----------"; echo "> "`pwd`; l | grep "^l"; ls -d */; l | grep "^-";'
alias      l='ls -lhA --color --time-style=long-iso'
alias     lt='l --sort=time'
alias     ld='ls */ -d'
alias     l.='ls -dlhA .??* --time-style=long-iso'
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
alias gow='cd /var/www      && l';
alias fs=' cd /fs           && l';
alias fsw='cd /fs/var/www   && l';
alias ch755='chmod -R 755 '
alias ch777='chmod -R 777 '
alias chwww='chown -R www-data:www-data '
alias chnobody='chown -R nobody:nogroup '
alias ackphp='ack --ignore-dir=node_modules --ignore-dir=vendor --ignore-dir=storage/framework --ignore-dir=storage '
alias diff='diff --color -ruB'

# command line helper
alias tail='tail -f '
alias copy='xclip -selection clipboard'

# get ip
alias getip="curl icanhazip.com"
alias getlocalip="ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'"

# copy files
#   >f        傳輸文件
#   cd        建立目錄
#   st        檔案大小 & 時間 不同, 表示檔案內容有異動
#   +++++++++ 新增檔案
#
alias jcp="rsync -avv --human-readable --itemize-changes --partial"


# --------------------------------------------------------------------------------
#   取代原有的功能
# --------------------------------------------------------------------------------

# https://github.com/kaelzhang/shell-safe-rm
alias rm='safe-rm'


# --------------------------------------------------------------------------------
#   Custom Functions
# --------------------------------------------------------------------------------

# 文字翻譯
# google translate
#   - https://www.npmjs.com/package/google-translate-cli
#
# example
#   translate -h | jtr
#   jtr "today is good day"
#
alias jtr='translate -s en -t zh-TW'


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

    echo "  "`TZ=America/Los_Angeles date "+%Z [%z] %Y-%m-%d %T"`"  LA     "
    echo "  "`TZ=UTC                 date "+%Z [%z] %Y-%m-%d %T"`"  UTC    "
    echo "  "`TZ=Asia/Taipei         date "+%Z [%z] %Y-%m-%d %T"`"  Taipei "
    echo

    #
    # while [ 1 ] ; do echo -en "  $(date +%Z\ [%z]\ %Y-%m-%d\ %T) \r" ; sleep 1; done
    #
    # 本來是使用上面的指令, 但不確定是不是 zsh 版本的關系, 現在 "[]" 這兩個符號前方要加上 backslash "\"
    while [ 1 ] ; do echo -en "  $(date +%Z\ \[%z\]\ %Y-%m-%d\ %T) \r" ; sleep 1; done
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

    if [ $ext = "md" ] ; then
        pandoc $1 | lynx -stdin
    elif [ $ext = "jpg" ] || [ $ext = "jpeg" ] || [ $ext = "gif" ] || [ $ext = "png" ] ; then
        file $1
    elif [ $ext = "php" ] || [ $ext = "js" ] || [ $ext = "css" ] ; then
        less -mN $1
    elif [ $ext = "conf" ] ; then
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
    elif [ $1 = "." ] ; then
        echo "You must describe a directory"
        return
    elif [ $1 = ".." ] || [ $1 = "../" ]; then
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

#
# fzf cat
#
jcat() {
    fzf --preview '[[ $(file --mime {}) =~ binary ]] && echo {} is a binary file || (rougify {}  || highlight -O ansi -l {} || coderay {} || cat {}) 2> /dev/null | head -500'
}

#
# fzf cd
#
jcd() {
  local dir
  dir=$(find ${1:-.} -path '*/\.*' -prune \
                  -o -type d -print 2> /dev/null | fzf +m) &&
  cd "$dir"
}

#
#
#
jlast() {
    last -i | awk '{print $3}' | sort | uniq -c
}


# --------------------------------------------------------------------------------
#   desktop editor
# --------------------------------------------------------------------------------

ed() {
    # EXEC="vi"
    # EXEC="gedit"
    # EXEC="subl"
    # EXEC="/opt/sublime_text/sublime_text"
    # EXEC="code"
    EXEC="code"

    $EXEC   # vscode 需要先開啟一次, 才不會讓之前開始的檔案列表都消失
    if [ -z "$1" ] ; then
        $EXEC "/fs/data/desktop/tmp.txt"
    elif [ "$1" = "..shell" ] || [ "$1" = "..sh" ] ; then
        $EXEC "/fs/var/www/tool/dotfiles/shell/ubuntu-shell/bash.sh"
    elif [ "$1" = "..bookmark" ] ; then
        $EXEC "/fs/000/Dropbox/work/common_text/page/bookmark.htm"
    else
        $EXEC $1
    fi
}

# --------------------------------------------------------------------------------
#   system information
# --------------------------------------------------------------------------------

jinfo() {
    clear

    echo '[$PATH]'
    # echo $PATH
    sed 's/:/\n/g' <<< "$PATH"

    echo 
    echo '[system]'
    uname -a
    lsb_release -a

    my_mysql="$(which mysql)"
    if [ ! -z "$my_mysql" ]
    then
        echo 
        echo '[mysql]'
        mysql -V
    fi

    my_openssl="$(which openssl)"
    if [ ! -z "$my_openssl" ]
    then
        echo 
        echo '[openssl]'
        openssl version
    fi

    my_apache2="$(which apache2)"
    if [ ! -z "$my_apache2" ]
    then
        echo 
        echo '[Apache]'
        apache2 -v
    fi

    my_nginx="$(which nginx)"
    if [ ! -z "$my_nginx" ]
    then
        echo 
        echo '[Nginx]'
        nginx -v
    fi

    my_php="$(which php)"
    if [ ! -z "$my_php" ]
    then
        echo 
        echo '[PHP]'
        php -v
    fi

}

# --------------------------------------------------------------------------------
#   git
#
#       npm install -g diff-so-fancy
#
# --------------------------------------------------------------------------------
alias       gl='clear; echo "---------- branch -v"; git branch -v; echo "---------- status"; git status -sb'
alias      gll='clear; echo "---------- branch -v"; git branch -v; echo "---------- log"; gitlog9 -n 12; echo "---------- status"; git status -sb'
alias       gd='git diff --color          | diff-so-fancy | less'
alias      gdc='git diff --color --cached | diff-so-fancy | less'

git_branch() {
    ref=$(git symbolic-ref HEAD 2> /dev/null) || return;
    echo "("${ref#refs/heads/}") ";
}

git_since_last_commit() {
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
alias testdox="php vendor/bin/phpunit --testdox"

alias art="php artisan"
alias migrate="php artisan migrate"
alias serve="artisan serve"
alias tinker="artisan tinker"
alias routelist="php artisan route:list"


# --------------------------------------------------------------------------------
#   phpbrew execute all fpm restart
# --------------------------------------------------------------------------------
jphpbrew_todo() {
    #
    tmp_content="/tmp/execute_phpbrew_fpm_restart.sh"

    #
    phpbrew list | grep php | cut -c 3- | awk -F' ' '{print("phpbrew use "$1" && phpbrew fpm restart")}' > $tmp_content
    echo '--------------------'
    cat $tmp_content

    #
    echo '--------------------'
    chmod +x $tmp_content
    source $tmp_content && rm $tmp_content

    #
    phpbrew list | head -n1 | awk -F' ' '{print("phpbrew use "$1)}' > $tmp_content
    chmod +x $tmp_content
    source $tmp_content && rm $tmp_content

    #
    echo '--------------------'
    phpbrew list
}


# --------------------------------------------------------------------------------
#
# --------------------------------------------------------------------------------
echo `TZ=Asia/Taipei        date "+%Z [%z] %Y-%m-%d %T"`" - Asia/Taipei"


