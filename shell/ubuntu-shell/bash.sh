#!/usr/bin/env bash

# --------------------------------------------------------------------------------
# Using wget or curl command
# --------------------------------------------------------------------------------
#
# source <( curl --insecure         https://raw.githubusercontent.com/glennfriend/dotfiles/master/shell/ubuntu-shell/bash.sh )
# sh <(curl -L                      https://raw.githubusercontent.com/glennfriend/dotfiles/master/shell/ubuntu-shell/bash.sh )
# sh <(wget --no-check-certificate  https://raw.githubusercontent.com/glennfriend/dotfiles/master/shell/ubuntu-shell/bash.sh -O -)
# wget -q -O -                      https://raw.githubusercontent.com/glennfriend/dotfiles/master/shell/ubuntu-shell/bash.sh | sh
# bash < <(wget -O -                https://raw.githubusercontent.com/glennfriend/dotfiles/master/shell/ubuntu-shell/bash.sh )
# bash < <(curl -s                  https://raw.githubusercontent.com/glennfriend/dotfiles/master/shell/ubuntu-shell/bash.sh )
#

# --------------------------------------------------------------------------------
#   前導函式
# --------------------------------------------------------------------------------
_strict_mode_start() {
    set -uo pipefail
    BACKUP_IFS="$IFS"
    IFS=$'\n\t'
}

_strict_mode_end() {
    set +u
    IFS="$BACKUP_IFS"
}

# --------------------------------------------------------------------------------
#   start
# --------------------------------------------------------------------------------
_strict_mode_start


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
alias    lll='echo; last -n20; echo "----------"; echo "timezone : "`cat /etc/timezone`; echo "boot-time: "`uptime -s`; echo "now      : "`date "+%Y-%m-%d %H:%M:%S"`; echo "----------";'
alias      l='ls -lhA --color --time-style=long-iso'
alias     lt='l --sort=time'
alias     ld='echo "> "`pwd`; echo ""; l | grep "^l"; ls -d */; l | grep "^-"';
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
alias goow='cd /opt/www     && l';
alias fs=' cd /fs           && l';
alias fsw='cd /fs/var/www   && l';
alias ch755='chmod -R 755 '
alias ch777='chmod -R 777 '
alias chwww='chown -R www-data:www-data '
alias chnobody='chown -R nobody:nogroup '
alias ack2='ack --ignore-dir=node_modules --ignore-dir=vendor --ignore-dir=storage/framework --ignore-dir=storage --ignore-dir=.next --type-set=DUMB=.log,.xml,.csv,.sql --noDUMB'
alias diff='diff --color -ruB'
alias emo='tip emoji-1'

# 在使用 sudo 的情況下, 可以使用到 user bash 裡面的指令
alias sudo='sudo '

# command line helper
alias head='head -n 40'
# alias tail='tail -n 40 -f'
# date | copy
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

# other
# alias mux="tmuxinator"

# --------------------------------------------------------------------------------
#   取代原有的功能
# --------------------------------------------------------------------------------

# https://github.com/kaelzhang/shell-safe-rm
# alias rm='safe-rm'
#
# rm to trash for ubuntu
# 查看垃圾桶使用 ls -la            ~/.local/share/Trash/files
# 有些檔案刪不掉 sudo chmod -R 777 ~/.local/share/Trash/files
# 清空垃圾桶使用 gio trash --empty
# 請注意: rm 本身就是 rm -rf 的功能 !
alias rm='gio trash'


# https://gist.github.com/premek/6e70446cfc913d3c929d7cdbfe896fef
# mv 如果後面只有輸入一個參數, 可以進入交互模式
# for zsh version
function mv() {
  if [ "$#" -ne 1 ] || [ ! -f "$1" ]; then
    command mv "$@"
    return
  fi

  newfilename="$1"
  vared newfilename
  command mv -v -- "$1" "$newfilename"
}


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
alias jtrl='translate -s en -t zh-TW | less'


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

    #
    # while [ 1 ] ; do echo -en "\r  $(date +%Z\ [%z]\ %Y-%m-%d\ %T)  " ; sleep 1; done
    #
    # 本來是使用上面的指令, 但不確定是不是 zsh 版本的關系, 現在 "[]" 這兩個符號前方要加上 backslash "\"
    while [ 1 ] ; do echo -en "\r  $(date +%Z\ \[%z\]\ %Y-%m-%d\ %T)  " ; sleep 1; done
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
        printf "\r%d <= %s " $i "$timeFormat"
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

    if [ "$ext" = "md" ] ; then
        pandoc "$1" | lynx -stdin
    elif [ "$ext" = "jpg" ] || [ "$ext" = "jpeg" ] || [ "$ext" = "gif" ] || [ "$ext" = "png" ] ; then
        file "$1"
    elif [ "$ext" = "php" ] || [ "$ext" = "js" ] || [ "$ext" = "css" ] ; then
        less -mN "$1"
    elif [ "$ext" = "conf" ] ; then
        less -mN "$1"
    else
        less -m "$1"
    fi
}

#
# 先備份, 後刪除
#
jrm() {

    left="\033[1;33m"
    right="\033[0m"

    absolute_path=$(readlink -m "$1")
    echo ">"
    echo "> rm -rf $left$absolute_path$right"
    echo ">"


    if [ -z "$1" ] ; then
        echo "Input delete folder or files"
        return
    elif [ "$1" = "." ] ; then
        echo "You must describe a directory"
        return
    elif [ "$1" = ".." ] || [ "$1" = "../" ]; then
        echo "You can not delete up floor directory"
        return
    fi

    now=$(date "+%m%d-%H%M%S")
    delete_folder="/tmp/delete/$now/"
    mkdir -p "$delete_folder"

    rsync -avv --human-readable --itemize-changes --partial "$1" "$delete_folder" && rm -rf "$1"
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

#
# ls guess
#
lg() {
    current_folder="${PWD##*/}"

    if [ -d "current" ] && [ -d "releases" ] && [ -d "repo" ] ; then
        # deploy folder
        l && l releases/
        return
    elif [ "${current_folder}" = "storage" ] && [ -d "app" ] && [ -d "framework" ] && [ -d "logs" ] ; then
        # laravel storage folder
        ls -lhA --color --time-style=long-iso
        ls -lhA --color --time-style=long-iso logs
        return
    else
        ls -lhA --color --time-style=long-iso
        return
    fi
}

# --------------------------------------------------------------------------------
#   解壓縮
# --------------------------------------------------------------------------------
unfile() {
    unset unfile_command
    if [[ -f $1 ]] ; then
        case $1 in
            *.tar.bz2)  unfile_command="tar xvjf $1"        ;;
            *.tar.gz)   unfile_command="tar xvzf $1"        ;;
            *.tar.xz)   unfile_command="tar Jxvf $1"        ;;
            *.bz2)      unfile_command="bunzip2 $1"         ;;
            *.rar)      unfile_command="unrar x $1"         ;;
            *.gz)       unfile_command="gunzip $1"          ;;
            *.tar)      unfile_command="tar xvf $1"         ;;
            *.tbz2)     unfile_command="tar xvjf $1"        ;;
            *.tgz)      unfile_command="tar xvzf $1"        ;;
            *.zip)      unfile_command="unzip $1"           ;;
            *.Z)        unfile_command="uncompress $1"      ;;
            *.7z)       unfile_command="7z x $1"            ;;
#           *.7z)       unfile_command="7zz x $1"           ;;
            *.lzma)     unfile_command="tar -Jxf $1"        ;;  # sudo apt-get install xz-utils
            *)          echo "'$1' cannot be extracted via >unfile<" ;;
        esac

        if [[ -n $unfile_command ]] ; then
            echo "> ""$unfile_command"
            echo 'Yes/No: '
            read yes_or_no
            echo ""

            if [[ $yes_or_no == "y" ]] || [[ $yes_or_no == "Y" ]] ; then
                bash -c "$unfile_command"
            fi
        fi

    else
        echo "'$1' is not a valid file"
    fi
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

    # vscode 需要先開啟一次, 才不會讓之前開始的檔案列表都消失
    $EXEC

    #
    if [ -z "$1" ] ; then
        $EXEC "/fs/data/desktop/tmp.txt"
    elif [ "$1" = "..shell" ] || [ "$1" = "..sh" ] ; then
        $EXEC "/fs/var/www/tool/dotfiles/shell/ubuntu-shell/bash.sh"
    elif [ "$1" = "..bookmark" ] ; then
        $EXEC "/fs/000/Dropbox/work/bookmark/page/bookmark.htm"
    else
        $EXEC "$1"
    fi
}

# --------------------------------------------------------------------------------
#   system information
# --------------------------------------------------------------------------------

jsystem() {
    clear

    echo '[PATH]'
    # echo $PATH
    sed 's/:/\n/g' <<< "$PATH"

    echo 
    echo '[system]'
    uname -a
    lsb_release -a

    echo 
    echo '[other]'
    echo 'System is '`getconf LONG_BIT `' bits'

    rotational="$(cat /sys/block/sda/queue/rotational)"
    if [[ "0" == "$rotational" ]]
    then
        echo 'HD is SSD';
    else
        echo 'HD is HDD';
    fi
}


jinfo() {
    clear

    my_php="$(command -v php)"
    if [ -n "$my_php" ]
    then
        echo '[PHP]'
        php -v
    fi

    my_mysql="$(command -v mysql)"
    if [ -n "$my_mysql" ]
    then
        echo 
        echo '[mysql]'
        mysql -V
    fi

    my_openssl="$(command -v openssl)"
    if [ -n "$my_openssl" ]
    then
        echo 
        echo '[openssl]'
        openssl version
    fi

    my_apache2="$(command -v apache2)"
    if [ -n "$my_apache2" ] && [ "apache2 not found" != "$my_apache2" ]
    then
        echo 
        echo '[Apache]'
        apache2 -v
    fi

    my_nginx="$(command -v nginx)"
    if [ -n "$my_nginx" ]
    then
        echo 
        echo '[Nginx]'
        nginx -v
    fi

}

# --------------------------------------------------------------------------------
#   git
#
#       npm install -g diff-so-fancy
#
# --------------------------------------------------------------------------------
alias  gl='clear; echo "---------- branch -v"; git branch -v; echo "---------- status"; git status -sb'

gdc() {
    TMP_FILE="$(mktemp)"
    git diff --color --cached $1 $2 $3 $4 $5 $6 $7 $8 $9 > "${TMP_FILE}"
    TMP_LINE=$(cat "${TMP_FILE}" | wc -l)

    if [[ TMP_LINE -ge 30 ]] ; then
        git diff --color --cached $1 $2 $3 $4 $5 $6 $7 $8 $9 | diff-so-fancy | less
    elif [[ TMP_LINE -ge 1 ]] ; then
        git diff --color --cached $1 $2 $3 $4 $5 $6 $7 $8 $9 | diff-so-fancy
    else
        # file is empty
        echo
    fi

    rm ${TMP_FILE}
}

unalias gd
gd() {
    TMP_FILE=$(mktemp)
    git diff --color $1 $2 $3 $4 $5 $6 $7 $8 $9 > "${TMP_FILE}"
    TMP_LINE=$(cat "${TMP_FILE}" | wc -l)

    if [[ TMP_LINE -ge 30 ]] ; then
        git diff --color $1 $2 $3 $4 $5 $6 $7 $8 $9 | diff-so-fancy | less
    elif [[ TMP_LINE -ge 1 ]] ; then
        git diff --color $1 $2 $3 $4 $5 $6 $7 $8 $9 | diff-so-fancy
    else
        # file is empty
        echo
    fi

    rm ${TMP_FILE}
}

# 現在目錄有 git 異動的檔案, 顯示最後一次 commit 時的 message
# list Git Last Commit message
#      ^   ^    ^
#
# glc() {
#     clear
#     git status -s | grep -v '?? ' | cut -c 4- | cut -d ' ' -f 1 | awk -F: '{ system("   \
#         echo " $1 " ; \
#         git log -n1 --pretty=\"  => %s\" " $1 " ; \
#         git log -n1 --pretty=\"  => %h\" " $1 " ; \
#         " "echo") }'
# }
#
glc() {
    clear
    git status -s | grep -v '?? ' | cut -c 4- | cut -d ' ' -f 1 | awk -F: '{ system("   \
        echo " $1 " ; \
        git log -n1 --pretty=\"  => %s\" " $1 " ; \
        git log -n1 --pretty=\"  => %h - %cr\" " $1 " ; \
        " "echo") }'
}


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
#alias migrate="php artisan migrate"
#alias serve="artisan serve"
#alias tinker="artisan tinker"
#alias routelist="php artisan route:list"


# --------------------------------------------------------------------------------
#   log rewrite
#
#   tail laravel log
#   tail wordpress log
#
# --------------------------------------------------------------------------------
log() {

    FILES=(`ls | sed 's/ /\n/g'`);

    # -eq   =
    # -ne   !=
    # -gt   >
    # -lt   <
    # -ge   >=
    # -le   <=

    #
    # wordpress
    #
    let TOTAL_COUNT=0
    for FILE in "${FILES[@]}"; do
        if [[ "$FILE" = "wp-includes" ]]; then
            TOTAL_COUNT=$TOTAL_COUNT+1;
        fi
        if [[ "$FILE" = "wp-settings.php" ]]; then
            TOTAL_COUNT=$TOTAL_COUNT+1;
        fi
        if [[ "$FILE" = "wp-cron.php" ]]; then
            TOTAL_COUNT=$TOTAL_COUNT+1;
        fi
    done

    LOG_FILE="wp-content/debug.log";
    if [[ TOTAL_COUNT -ge 3 ]] && [ -f $LOG_FILE ] ; then
        echo -e tail -f $LOG_FILE
        echo
        tail -f $LOG_FILE
    fi

    #
    # laravel
    #
    let TOTAL_COUNT=0
    for FILE in "${FILES[@]}"; do
        if [[ "$FILE" = "artisan" ]]; then
            TOTAL_COUNT=$TOTAL_COUNT+1;
        fi
        if [[ "$FILE" = "bootstrap" ]]; then
            TOTAL_COUNT=$TOTAL_COUNT+1;
        fi
        if [[ "$FILE" = "routes" ]]; then
            TOTAL_COUNT=$TOTAL_COUNT+1;
        fi
    done

    # 正常情況, 以系統為時區, 使用以下方式
    #   TODAY=`date +"%Y-%m-%d"`;
    # 實務上, 是吃 laravel 裡面 timezone 的設定, 這裡為了簡化, 直接指定時區
    TODAY=`TZ=America/Los_Angeles date +"%Y-%m-%d"`
    LOG_FILE="storage/logs/laravel-${TODAY}.log";
    if [[ TOTAL_COUNT -ge 3 ]] && [ -f $LOG_FILE ] ; then
        echo -e tail -f $LOG_FILE
        echo
        tail -f $LOG_FILE
    fi

    LOG_FILE="storage/logs/laravel.log";
    if [[ TOTAL_COUNT -ge 3 ]] && [ -f $LOG_FILE ] ; then
        echo -e tail -f $LOG_FILE
        echo
        tail -f $LOG_FILE
    fi

}


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
#   test only
# --------------------------------------------------------------------------------





# --------------------------------------------------------------------------------
#   end
# --------------------------------------------------------------------------------
echo `TZ=Asia/Taipei        date "+%Z [%z] %Y-%m-%d %T"`" - Asia/Taipei"
_strict_mode_end
