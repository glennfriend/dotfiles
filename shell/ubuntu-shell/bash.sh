#!/usr/bin/env bash


#set -o errexit      # 發生錯誤時, 包含 Ctrl + c , 程式終止
set -o nounset      # 使用沒有設定的變數, 程式終止
set -o pipefail     # 這將確保 pipeline 命令被視為失敗，即使 pipeline 中的一個命令失敗
if [[ "${TRACE-0}" == "1" ]]; then set -o xtrace; fi    # TRACE=1 ./bash.sh


# --------------------------------------------------------------------------------
# Using wget or curl command
# --------------------------------------------------------------------------------
#
# source <( curl -sS --insecure     https://raw.githubusercontent.com/glennfriend/dotfiles/master/shell/ubuntu-shell/bash.sh )
# sh <(curl -L                      https://raw.githubusercontent.com/glennfriend/dotfiles/master/shell/ubuntu-shell/bash.sh )
# sh <(wget --no-check-certificate  https://raw.githubusercontent.com/glennfriend/dotfiles/master/shell/ubuntu-shell/bash.sh -O -)
# bash < <(curl -sS                 https://raw.githubusercontent.com/glennfriend/dotfiles/master/shell/ubuntu-shell/bash.sh )
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
alias got='cd ~/tools       && l';
alias gossh='cd ~/.ssh      && l';
alias fs=' cd /fs           && l';
alias fsw='cd /fs/var/www   && l';
alias ch755='chmod -R 755 '
alias ch777='chmod -R 777 '
alias chwww='chown -R www-data:www-data '
alias chnobody='chown -R nobody:nogroup '
alias ack2='ack --ignore-dir=node_modules --ignore-dir=vendor --ignore-dir=storage/framework --ignore-dir=storage --ignore-dir=.next  --ignore-file=ext:cache  --type-set=DUMB=.log,.xml,.csv,.sql,.lock,.phar --noDUMB'
alias diff='diff --color -ruB'
alias emo='tip emoji-1'
# paplay --> sudo apt install pulseaudio-utils
alias beep='paplay  /usr/share/sounds/sound-icons/xylofon.wav'
alias beep-finish='paplay  /fs/data/sound/finish.wav'
alias beep-alert='paplay   /fs/data/sound/alert.wav'
alias folder='nautilus'
alias myip='curl wtfismyip.com/json'


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
alias jcp="rsync -avv --human-readable --itemize-changes --partial "

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
# alias rm='gio trash'


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
#   composer bin
# --------------------------------------------------------------------------------
# mkdir -p ~/tools/bartlett_umlwriter
# cd       ~/tools/bartlett_umlwriter
# echo     '{}' >> composer.json
# composer config minimum-stability dev
# composer require bartlett/umlwriter:3.1.1
# alias php-plantuml='~/tools/bartlett_umlwriter/vendor/bin/umlwriter'
# 以上不成功, 可能會移除

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
    local url="https://raw.githubusercontent.com/glennfriend/dotfiles/master/shell/ubuntu-shell/bash.sh"
    source <( curl --insecure {$url} )
}

# create folder
jmkdir() {
    mkdir -p -- "$1" &&
    cd -P -- "$1"

    # cd $_
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

jdate2() {
    echo "PST -8 太平洋標準時間 Pacific Standard Time"
    echo "PDT -7 太平洋夏令時間 Pacific Daylight Time 日光節約時間"
    echo "  "`TZ=Asia/Taipei         date "+%Z [%z] %Y-%m-%d %T"`"  Taipei "
    echo "  "`TZ=UTC                 date "+%Z [%z] %Y-%m-%d %T"`"  UTC    "
    echo "  "`TZ=America/New_York    date "+%Z [%z] %Y-%m-%d %T"`"  NY     "
    echo "  "`TZ=America/Chicago     date "+%Z [%z] %Y-%m-%d %T"`"  Chicago"
    echo "  "`TZ=America/Denver      date "+%Z [%z] %Y-%m-%d %T"`"  Denver"
    echo "  "`TZ=America/Los_Angeles date "+%Z [%z] %Y-%m-%d %T"`"  LA     "
}


# 到數計時器
jsleep() {
    if [ -z "$1" ]
        then
            echo "No arguments supplied"
            return
    fi

    for ((i = $1; i >= 1; i--)); do
        local timeFormat=$(date -u -d@$(($i)) +"%H:%M:%S")
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

    local filename=$(basename "$1")
    local ext="${filename##*.}"
    local filename="${filename%.*}"

    #echo $filename
    #echo $ext

    if [ "$ext" = "md" ] ; then
        pandoc "$1" | lynx -stdin
    elif [ "$ext" = "jpg" ] || [ "$ext" = "jpeg" ] || [ "$ext" = "gif" ] || [ "$ext" = "png" ] ; then
        file "$1"
        eog "$1" &
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

    local left="\033[1;33m"
    local right="\033[0m"
    local absolute_path=$(readlink -m "$1")
    echo ">"
    echo "> rm -rf ${left}${absolute_path}${right}"
    echo ">"


    if [ -z "$1" ] ; then
        echo "Input delete folder or files"
        return
    elif [ "$1" = "/" ] ; then
        echo "You can not delete root"
        return
    elif [ "$1" = "." ] ; then
        echo "You must describe a directory"
        return
    elif [ "$1" = ".." ] || [ "$1" = "../" ]; then
        echo "You can not delete up floor directory"
        return
    fi

    local now=$(date "+%m%d-%H%M%S")
    local delete_folder="/tmp/delete/$now/"
    mkdir -p "$delete_folder"

    rsync -avv --human-readable --itemize-changes --partial "$1" "$delete_folder" && gio trash "$1"
    echo ""
    echo "rsync -avv --human-readable --itemize-changes --partial $1 $delete_folder && gio trash $1"
    echo "ls -la $delete_folder"
    echo "ls -la $delete_folder" | xclip -selection clipboard
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
    local current_folder="${PWD##*/}"

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

jnotify() {
    beep
    notify-send "Notify Task :-)"
    jdate
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

# 主機版型號
#   sudo lshw -short
#   sudo dmidecode -t 2
jsystem() {
    clear

    echo '[PATH]'
    # echo $PATH
    sed 's/:/\n/g' <<< "$PATH"

    echo 
    echo '[system]'
    uname -s -n -r -m -o    # uname -a
    lsb_release -a

    machine="$(uname -m)"
    echo -n "$machine:         ";
    if [ "$machine" = "aarch64" ] || [ "$machine" = "arm64" ] ; then
        echo 'ARM64 架構';
    elif [ "$machine" = "x86_64" ] ; then
        echo '64 位元的 x86 架構';
    fi


    echo 
    echo '[other]'
    echo 'System is '`getconf LONG_BIT `' bits'
    echo $XDG_CURRENT_DESKTOP


    for disk in $(ls /sys/block | grep -E 'sd|nvme|vd'); do
        if [ -e /sys/block/$disk/queue/rotational ]; then
            rota=$(cat /sys/block/$disk/queue/rotational)
            if [ $rota -eq 0 ]; then
                echo "$disk is an SSD"
            else
                echo "$disk is an HDD"
            fi
        fi
    done
}


jsystem2() {
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

    my_docker="$(command -v docker)"
    if [ -n "$my_docker" ]
    then
        echo 
        echo '[Docker like]'
        docker -v
        docker-compose -v
    fi

}

# --------------------------------------------------------------------------------
#   git
#
#       install https://github.com/dandavison/delta
#       [deprecated] npm install -g diff-so-fancy
#
# --------------------------------------------------------------------------------
unalias gl  2>/dev/null
# alias    gls='clear; echo "---------- branch -v"; git branch -v; echo "---------- status"; git status -sb'
gls() {
    clear; 
    echo "---------- branch -v"; 
    git branch -v; 
    echo "---------- status"; 
    git status -sb
}

unalias glg 2>/dev/null
glg() {
    if git show-ref --verify --quiet refs/heads/master; then
        git log @ ^master --oneline --graph
        echo
        git log master -1 --oneline
    elif git show-ref --verify --quiet refs/heads/main; then
        git log @ ^main --oneline --graph
        echo
        git log main -1 --oneline
    else
        git log @ --oneline --graph
    fi
}



# 測試中的功能
alias    gdw=' GIT_EXTERNAL_DIFF=difft gd '
alias    gdcw='GIT_EXTERNAL_DIFF=difft gdc '

# 該指令同於 zsh 內建的 git ggpush 指令, 原本的如下
# alias gggpush='git push origin "$(git_current_branch)"'
unalias ggpush 2>/dev/null
ggpush() {
    BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
    if [[ "$BRANCH_NAME" = "master" ]]; then
        echo "Fail ! you can not push to master"
        return
    fi
    if [[ "$BRANCH_NAME" = "main" ]]; then
        echo "Fail ! you can not push to main"
        return
    fi

    git push origin "$(git_current_branch)" --force-with-lease $1 $2 $3
}



gdc() {
    git diff --cached $1 $2 $3 $4 $5 $6 $7 $8 $9
}
# gdc() {
#     TMP_FILE="$(mktemp)"
#     git diff --color --cached $1 $2 $3 $4 $5 $6 $7 $8 $9 > "${TMP_FILE}"
#     TMP_LINE=$(cat "${TMP_FILE}" | wc -l)
# 
#     if [[ TMP_LINE -ge 30 ]] ; then
#         git diff --color --cached $1 $2 $3 $4 $5 $6 $7 $8 $9 | diff-so-fancy | less
#     elif [[ TMP_LINE -ge 1 ]] ; then
#         git diff --color --cached $1 $2 $3 $4 $5 $6 $7 $8 $9 | diff-so-fancy
#     else
#         # file is empty
#         echo
#     fi
# 
#     rm ${TMP_FILE}
# }

unalias gd  2>/dev/null
gd() {
    git diff --color $1 $2 $3 $4 $5 $6 $7 $8 $9
}
# gd-old() {
#     TMP_FILE=$(mktemp)
#     git diff --color $1 $2 $3 $4 $5 $6 $7 $8 $9 > "${TMP_FILE}"
#     TMP_LINE=$(cat "${TMP_FILE}" | wc -l)
# 
#     if [[ TMP_LINE -ge 30 ]] ; then
#         git diff --color $1 $2 $3 $4 $5 $6 $7 $8 $9 | diff-so-fancy | less
#     elif [[ TMP_LINE -ge 1 ]] ; then
#         git diff --color $1 $2 $3 $4 $5 $6 $7 $8 $9 | diff-so-fancy
#     else
#         # file is empty
#         echo
#     fi
# 
#     rm ${TMP_FILE}
# }

# 現在目錄有 git 異動的檔案, 顯示最後一次 commit 時的 message
# list Git Last Commit message
#      ^   ^    ^
#
# glsc() {
#     clear
#     git status -s | grep -v '?? ' | cut -c 4- | cut -d ' ' -f 1 | awk -F: '{ system("   \
#         echo " $1 " ; \
#         git log -n1 --pretty=\"  => %s\" " $1 " ; \
#         git log -n1 --pretty=\"  => %h\" " $1 " ; \
#         " "echo") }'
# }
#
glsc() {
    clear
    git diff --name-only --cached | awk -F: '{ system("   \
        echo " $1 "         ; \
        echo -n \"  [guess] -- \"   ; \
        ciname "$1"         ; \
        echo \"    \" ; \
        git log -n1 --pretty=\"  [befor] -- %s\" " $1 "         ; \
        git log -n1 --pretty=\"  [hash ] -- %h - %cr\" " $1 "   ; \
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

# go to git root path
# alias gitroot='cd "$(git rev-parse --show-toplevel)"'




# --------------------------------------------------------------------------------
#   github gh cli
#       未來可能改成 ??
#       mygh issue create
#       mygh pr create
#
# --------------------------------------------------------------------------------
gh-issue-create() {
    check="$(command -v php)"
    if [ -z "$check" ]; then
        echo "please to install `php`"
        return
    fi

    check="$(command -v gh)"
    if [ -z "$check" ]; then
        echo "please to install `gh`: https://github.com/cli/cli/blob/trunk/docs/install_linux.md"
        return
    fi

    # default
    local label="chore"

    while [[ $# -gt 0 ]]; do
        key="$1"
        case $key in
            --title=*)
                title="${key#*=}"
                ;;
            --url=*)
                url="${key#*=}"
                ;;
            --label=*)
                label="${key#*=}"
                ;;
            --custom_issue=*)
                custom_issue="${key#*=}"
                ;;
            *)
                # Unknown option
                ;;
        esac
        shift
    done

    # check params
    if [ -z "$title" ] || [ -z "$url" ]; then
        echo "command example"
        echo "   " $0 '--label="chore" --title="" --url=""'
        echo
        echo "description"
        echo
        echo "   " "--title"
        echo "       " "github title"
        echo
        echo "   " "--url"
        echo "       " "link to task card url"
        echo
        echo "   " "--custom_issue"
        echo "       " "issue id: 1234, T2234"
        echo "       " "做為開頭編號使用"
        echo
        echo "   " "--label"
        echo "       " "chore, feat, bug, enhancement"
        return
    fi

    COMMAND="gh issue create --assignee @me --label \"${label}\" --title \"${title}\" --body \"${url}\" "
    echo
    echo "-> ${COMMAND}"
    if [ -n "$custom_issue" ] ; then
        echo "-> custom issue=""$custom_issue"
    fi

    # Prompt for confirmation to continue
    echo -n "Continue (y/N): "
    read RESPONSE
    if [[ ! "$RESPONSE" =~ ^[Yy]$ ]]; then
        echo "exit 0"
        return
    fi

    # issue create
    # get like "https://github.com/username/project/issues/100"
    eval ${COMMAND} > /tmp/gh.1

    # 取得 issue number
    REGEX='/issues\/([0-9]+)/'
    cat /tmp/gh.1 | php -R "preg_match('$REGEX', \$argn, \$matches); echo \$matches[1];" | read GITHUB_ISSUE_ID
    # check ISSUE
    if [ -z "$GITHUB_ISSUE_ID" ] ; then
        echo "create failed !"
        return
    fi

    # 如果已經有填 $issue, 就不用使用 github issue id 做為 prefix
    if [ -z "$custom_issue" ] ; then
        issue=$GITHUB_ISSUE_ID
    else
        issue=$custom_issue
    fi

    # branch name
    echo "${label}-${title}" | sed -r 's/([a-z0-9]+)/\L\1/ig' | sed -r 's/[\.\":]+//g' | sed -e 's/\[//g' -e 's/\]//g' | sed -r 's/[\.\,\_\ \-]+/-/g' | read BRANCH_NAME
    BRANCH_NAME="${issue}-${BRANCH_NAME}"

    # show information
    echo
    echo "## issue ${issue}"
    echo "## branch ${BRANCH_NAME}"
    echo "-> gh issue develop ${GITHUB_ISSUE_ID} --name ${BRANCH_NAME}"
    echo
    echo ">>>>"
    gh issue develop ${GITHUB_ISSUE_ID} --name ${BRANCH_NAME}
    echo "<<<<"
    echo
    echo "## continue"
    echo "    git checkout ${BRANCH_NAME}"

}

gh-pr-create() {
    BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
    # BRANCH_NAME="100-feat-your-title"
    ISSUE=$(echo $BRANCH_NAME | cut -d '-' -f 1)
    LABEL=$(echo $BRANCH_NAME | cut -d '-' -f 2)
    TITLE=$(echo $BRANCH_NAME | cut -d '-' -f 3-)

    if [ "$ISSUE" = "master" ] || [ "$LABEL" = "master" ] || [ "$TITLE" = "master" ] ; then
        echo "請切到 target branch"
        return
    fi
    if [ -z "$ISSUE" ] || [ -z "$LABEL" ] || [ -z "$TITLE" ]; then
        echo "請切到 target branch."
        return
    fi

    while [[ $# -gt 0 ]]; do
        key="$1"
        case $key in
            --reviewer=*)
                reviewer="${key#*=}"
                ;;
            *)
                # Unknown option
                ;;
        esac
        shift
    done


    TITLE_FORMAT=$(echo "$TITLE" | sed 's/-/ /g' | php -r 'echo ucfirst(fgets(STDIN));')
    COMMAND="gh pr create --title \"${TITLE_FORMAT}\" --body \"#${ISSUE}\" --assignee @me --label \"${LABEL}\" --draft --reviewer \"${reviewer}\" "
    echo
    echo "## Tips: 至少要有一個 commit push 才能建立 pull request"
    echo "-> ${COMMAND}"

    # Prompt for confirmation to continue
    echo -n "Continue (y/N): "
    read RESPONSE
    if [[ ! "$RESPONSE" =~ ^[Yy]$ ]]; then
        echo "exit 0"
        return
    fi


    # gh pr create --title "${TITLE}" --body "#${ISSUE}" --assignee @me --label "${LABEL}" --web
    # gh pr create --title "${TITLE}" --body "#${ISSUE}" --assignee @me --label "${LABEL}" --draft --reviewer "alice,bob"
    echo ">>>>"
    eval ${COMMAND} > /tmp/gh.1
    echo "<<<<"

    # TODO: debug, will remove it
    echo "result:"
    cat /tmp/gh.1
}

# --------------------------------------------------------------------------------
#   PHP, Laravel
# --------------------------------------------------------------------------------
alias testdox="php vendor/bin/phpunit --testdox"

alias art="php artisan"
#alias migrate="php artisan migrate"
#alias serve="artisan serve"
#alias routelist="php artisan route:list"


# tinker 'User::first()'
function tinker()
{
    if [ -z "$1" ]
        then
            php artisan tinker
        else
            php artisan tinker --execute="dd($1);"
    fi
}
function dtinker()
{
    if [ -z "$1" ]
        then
            docker-compose exec 'php7' php artisan tinker
        else
            docker-compose exec 'php7' php artisan tinker --execute="dd($1);"
    fi
}

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
    if [ -z "$(command -v nginx)" ]
    then
        echo 'nginx not exists'
        return
    fi

    #
    tmp_content="/tmp/execute_phpbrew_fpm_restart.sh"

    #
    phpbrew list | grep php | cut -c 3- | sort | awk -F' ' '{print("phpbrew use "$1" && phpbrew fpm restart")}' > $tmp_content
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
#   curl
# --------------------------------------------------------------------------------

# jurl 
function jurl()
{
    # if ! command -v pygmentize; then
    #     echo "-> sudo apt-get install python-pygments"
    # fi
    if [ -z "$1" ]
        then
            echo "No arguments url"
            return
    fi
    if [ -z "${Authorization}" ]
        then
            echo '-> Authorization="Bearer xxx.xxxxxx.xxx"'
            return
    fi

    # curl -kis

    # curl -ks "$1" \
    curl -ks "$@" \
        -H "Authorization: ${Authorization}" \
        -H 'Accept: application/json, text/plain, */*' \
        -H 'Content-Type: application/json;charset=utf-8' \
        --compressed
}

# --------------------------------------------------------------------------------
#   jq
# --------------------------------------------------------------------------------

# jq json log
# {
#     "message": "update contact skip",
#     "reason": "contact is opt out",
#     "error_message": "contact phone_number not found"
# }
function jqjsonlog()
{
    if [ -z "$1" ]
        then
            echo "No arguments supplied"
            return
    fi

    local FILE="$1"
    local ERROR=$(  cat ${FILE} | jq .error_message | sort -h | uniq -c)
    local REASON=$( cat ${FILE} | jq .reason        | sort -h | uniq -c)
    local MESSAGE=$(cat ${FILE} | jq .message       | sort -h | uniq -c)

    #
    local ERROR_COUNT=$(echo ${ERROR} | wc -l)
    if [[ "1" == ${ERROR_COUNT} ]] ; then
        echo -e "\033[1;36m[error message]\033[0m nothing"
    else
        echo -e "\033[1;36m[error message]\033[0m"
        echo $ERROR
    fi

    #
    echo
    local REASON_COUNT=$(echo ${REASON} | wc -l)
    if [[ "1" == ${REASON_COUNT} ]] ; then
        echo -e "\033[1;36m[reason]\033[0m nothing"
    else
        echo -e "\033[1;36m[reason]\033[0m"
        echo $REASON
    fi

    #
    echo
    echo -e "\033[1;36m[message]\033[0m"
    echo $MESSAGE
}



# --------------------------------------------------------------------------------
#   test only
# --------------------------------------------------------------------------------





# --------------------------------------------------------------------------------
#   end
# --------------------------------------------------------------------------------
echo `TZ=Asia/Taipei        date "+%Z [%z] %Y-%m-%d %T"`" - Asia/Taipei"
_strict_mode_end
