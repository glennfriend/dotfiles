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
export EDITOR=vi
export VISUAL=vi

# --------------------------------------------------------------------------------
#   custom
# --------------------------------------------------------------------------------
#
alias    lll='echo; last -n20; echo "----------"; echo "timezone : "`cat /etc/timezone`; echo "boot-time: "`uptime -s`; echo "now      : "`date "+%Y-%m-%d %H:%M:%S"`; echo "----------";'
alias      l='ls -lhA --color --time-style=long-iso'
alias     lt='l --sort=time'
alias     ld='l | grep "^-" ; l | grep "^l"; ls -d */; echo "> "`pwd`;';
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
alias ack2='ack --ignore-dir=node_modules --ignore-dir=vendor --ignore-dir=storage/framework --ignore-dir=storage --ignore-dir=.next  --ignore-file=ext:cache  --type-set=DUMB=.log,.xml,.csv,.sql,.lock,.phar --noDUMB'
#alias diff='diff --color -ruB'
alias diff='function _ddelta(){ git diff --no-index --color=always "$1" "$2" | delta; }; _ddelta'
alias emo='tip emoji-1'
alias folder='nautilus'
alias myip='curl wtfismyip.com/json'


# 在使用 sudo 的情況下, 可以使用到 user bash 裡面的指令
alias sudo='sudo '

# command line helper
alias head='head -n 40'
# alias tail='tail -n 40 -f'
# date | copy
alias copy='head -c -1 | xclip -selection clipboard'
pwdcp() {
    pwd | copy
}

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
#   sound
# --------------------------------------------------------------------------------
# paplay --> sudo apt install pulseaudio-utils
alias beep-clock='paplay  /usr/share/sounds/sound-icons/xylofon.wav'
alias beep-finish='paplay /fs/data/sound/finish.wav'
alias beep-alert='paplay  /fs/data/sound/alert.wav'

# 依照前面指令成功與否顯示聲音
# false ; beep ; true ; beep
beep() {
  local last="$?"
  if [[ "$last" == '0' ]]; then
    beep-finish
  else
    beep-alert
  fi
  # $(exit "$last")
  return "$last"
}

#
# echo 'hello, 你好' | speak
# cat README.md | speak
#
speak () {
    if ! hash php 2>/dev/null; then
        >&2 echo "-> sudo apt install php"
        return
    fi
    if ! hash pandoc 2>/dev/null; then
        >&2 echo "-> sudo apt install pandoc"
        return
    fi
    if ! hash mpv 2>/dev/null; then
        >&2 echo "-> sudo apt install mpv"
        return
    fi

    # 將 Markdown 轉成純文字
    local text=$(pandoc -f commonmark -t plain --wrap=preserve)
    
    # 限制為整篇文字的前 n 個字符
    text=$(echo "$text" | head -c 200)
    
    # 如果文字為空，則返回
    if [ -z "$text" ]; then
        >&2 echo "No text to speak"
        return
    fi
    
    # 設定語言
    # local lang="${SPEAK_LANG:-zh-TW}"
    local lang="${SPEAK_LANG:-en-US}"
    
    # 建立 /tmp/speak/ 目錄
    mkdir -p /tmp/speak
    
    # 計算文字的 hash 值作為檔案名稱
    local text_hash=$(echo "$text" | sha256sum | cut -d' ' -f1)
    local audio_file="/tmp/speak/${text_hash}.mp3"
    
    # 檢查音訊檔案是否已存在
    if [ -f "$audio_file" ]; then
        echo "cache hit: $audio_file"
        # 播放已存在的音訊檔案
        mpv --no-video --really-quiet "$audio_file"
    else
        echo "cache miss: $audio_file"

        # URL 編碼文字（使用 PHP 正確處理中文字符）
        local encoded_text=$(echo "$text" | php -r "echo urlencode(file_get_contents('php://stdin'));")

        # 使用 Google Translate TTS API
        local tts_url="https://translate.google.com/translate_tts?ie=UTF-8&q=${encoded_text}&tl=${lang}&client=tw-ob"
        
        # 下載音訊檔案到指定位置
        if curl -s -A "Mozilla/5.0" "$tts_url" -o "$audio_file"; then
            # 播放音訊檔案
            mpv --no-video --really-quiet "$audio_file"
        else
            >&2 echo "無法從 Google Translate 獲取音訊"
        fi
    fi

    # ls -la /tmp/speak/
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
#   - npm install -g google-translate-cli
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

    notify-send "Time's up"
    # beep-clock &
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
        set +m  # 關閉 job control
        nohup eog "$1" >/dev/null 2>&1 &
        set -m
        disown  # 不會追蹤背景工作, 關閉時也不會顯示 done 訊息
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
# fzf cat - 模糊搜尋檔案並預覽，選中後複製路徑到剪貼簿
#
jcat() {
    local preview_cmd='
        if [[ $(file --mime {}) =~ binary ]]; then
            echo "{} is a binary file"
        else
            bat --color=always          {} 2>/dev/null \
              || batcat --color=always  {} 2>/dev/null \
              || highlight -O ansi -l   {} 2>/dev/null \
              || coderay                {} 2>/dev/null \
              || cat {}
        fi | head -500
    '

    fzf --preview-window=right:70%:wrap --preview "$preview_cmd" | copy
    echo -n "copy to Clipboard"
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

#
# ls -la | copysearch ".env"
# >>>>
# -rw-rw-r--    1 ubuntu ubuntu   2072 Nov 12  2024 .env
#
copysearch() {
    if [ $# -eq 0 ]; then
        echo "Usage: command | copysearch <search_text>" >&2
        echo "  Example: cat .env | copysearch DB_DATABASE" >&2
        echo "  Example: tools/tinker/run.sh | grep php | copysearch test-" >&2
        echo "  Example: ls -la tools/tinker/ | grep php | copysearch test-" >&2
        
        return 1
    fi

    search_text="$1"

    while IFS= read -r line; do
        if [[ "$line" == *"$search_text"* ]]; then
            # 去除前後空白
            trimmed_line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            echo "$trimmed_line" | xclip -selection clipboard
            echo "Copied to Clipboard: $trimmed_line"
            return 0
        fi
    done

    echo "Nothing can be copied" >&2
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

jsys() {
    clear
    echo 'last'
    last -i | awk '{print $3}' | sort | uniq -c | sort -nr

    echo
    echo 'ps'
    jps | awk '{print $2}' | sort | uniq -c | sort -nr | head -n 15

    # | awk '$1 >= 6'
}

jsys2() {
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
        echo '[Docker]'
        docker -v
        docker compose version
    fi

    echo
    echo '[PATH]'
    # echo $PATH
    sed 's/:/\n/g' <<< "$PATH"
}


# 主機版型號
#   sudo lshw -short
#   sudo dmidecode -t 2
jsys3() {
    clear

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
    echo "XDG current desktop: $XDG_CURRENT_DESKTOP"
    echo "XDG session type   : $XDG_SESSION_TYPE"


    for disk in $(ls /sys/block | grep -E 'sd|nvme|vd'); do
        if [ -e /sys/block/$disk/queue/rotational ]; then
            rota=$(cat /sys/block/$disk/queue/rotational)
            if [ $rota -eq 0 ]; then
                echo "disk: SSD -> $disk"
            else
                echo "disk: HDD -> $disk"
            fi
        fi
    done
}

#
# like `ps -aux`
#
jps() {
    ps -eo pid,command \
        | grep -v "/google/chrome/chrome" \
        | grep -v "/usr/lib/firefox/firefox" \
        | grep -v "/usr/share/code" \
        | grep -v "/usr/bin/zsh" \
        | grep -v "/.cache/JetBrains/" \
        | grep -v "/.nvm/versions/node/" \
        | grep -v "/proc/self/exe " \
        | grep -v " zsh" \
        | grep -v " -zsh" \
        | grep -v " cat" \
        | grep -v "\[kworker/" \
        | grep -v "ps -eo pid,command"

    # "\[sh] <defunct>"
}


# --------------------------------------------------------------------------------
#   git
#
#       install https://github.com/dandavison/delta
#       [deprecated] npm install -g diff-so-fancy
#
# --------------------------------------------------------------------------------
unalias gl  2>/dev/null

# git ls
gls() {
    clear; 
    echo "---------- branch -v"; 
    git branch -v; 
    echo "---------- status"; 

    # 設定 git config core.quotepath false -> 正確顯示 UTF-8
    # 設定 git config core.quotepath true  -> "中" 會顯示為 "\344\270\255"
    git -c core.quotepath=false status -sb
}

# git log
unalias glg 2>/dev/null
glg() {
    if git show-ref --verify --quiet refs/heads/master; then
        git log --oneline --graph @ ^master
        echo
        git log --oneline master -1
    elif git show-ref --verify --quiet refs/heads/main; then
        git log --oneline --graph @ ^main
        echo
        git log --oneline main -1
    else
        git log --oneline --graph @
    fi
}

# glg2() {
#     if git show-ref --verify --quiet refs/heads/master; then
#         ref=master
#     elif git show-ref --verify --quiet refs/heads/main; then
#         ref=main
#     else
#         ref=""
#     fi
# 
#     if [ -n "$ref" ]; then
#         echo "Diff from $ref"
#         git log --graph --pretty=format:'%an %-20s | %h | %s' @ ^$ref
#         echo
#         echo "Latest commit on $ref"
#         git log -1 --pretty=format:'%an %-20s | %h | %s' $ref
#     else
#         git log --graph --pretty=format:'%an %-20s | %h | %s' @
#     fi
# }



gpr() {
    # git pull request
    # 查看最近誰推了哪些分支
    # git fetch origin --prune
    # git for-each-ref --sort=-committerdate --format='%(committerdate:iso8601) %(refname:short)' refs/remotes/origin | head -n 10

    git for-each-ref --sort=-committerdate --format='%(authorname) | %(committerdate:iso8601) | %(refname:short)' refs/remotes/origin \
        | awk -F'|' '{ printf "%-10.10s | %s | %s\n", $1, $2, $3 }' | head -n 10

}

gci() {
    # git commit message
    # 查看最近的 commit message
    git log -n 20 --pretty=format:"%an|%ad|%s" --date=iso \
        | awk -F'|' '{ printf "%-10.10s | %-25s | %s\n", $1, $2, $3 }'
}

# 測試中的功能
alias    gdw=' GIT_EXTERNAL_DIFF=difft gd '
alias    gdcw='GIT_EXTERNAL_DIFF=difft gdc '

# 測試中的功能
batdiff() {
    git diff --name-only --relative --diff-filter=d | xargs bat --diff
}










# 該指令同於 zsh 內建的 git ggpush 指令, 原本的如下
# alias gggpush='git push origin "$(git_current_branch)"'
unalias ggpush 2>/dev/null
ggpush() {
    BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)

    if [[ "$BRANCH_NAME" = "master" ]]; then
        echo -n "You are to push to [$BRANCH_NAME]. Type 'master' to confirm: "
        read CONFIRMATION
        if [[ "$CONFIRMATION" != "master" ]]; then
            echo "Fail! Push to '$BRANCH_NAME' aborted."
            return
        fi
    fi

    if [[ "$BRANCH_NAME" = "main" ]]; then
        echo -n "You are to push to [$BRANCH_NAME]. Type 'main' to confirm: "
        read CONFIRMATION
        if [[ "$CONFIRMATION" != "main" ]]; then
            echo "Fail! Push to '$BRANCH_NAME' aborted."
            return
        fi
    fi

    git push origin "$(git_current_branch)" --force-with-lease $1 $2 $3
}


# git diff for cached
gdc() {
    git -c core.quotepath=false diff --cached $1 $2 $3 $4 $5 $6 $7 $8 $9
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


# git diff
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
alias gitroot='cd "$(git rev-parse --show-toplevel)"'

# 切換 branch
branch() {
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        pwd
        echo "tips: 該目錄不包含 git repository"
        return
    fi

    # 檢查是否有未 commit 的修改, 忽略 submodule hash
    if ! git diff-index --quiet --ignore-submodules HEAD --; then
        gls
        echo "tips: You have uncommitted changes !"
        return
    fi

    echo
    git checkout "$(git branch -v | fzf | awk '{print $1}')"
    git branch -v
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

    LOG_FILE="shared/storage/logs/laravel-${TODAY}.log";
    if [[ TOTAL_COUNT -ge 3 ]] && [ -f $LOG_FILE ] ; then
        echo -e tail -f $LOG_FILE
        echo
        tail -f $LOG_FILE
    fi

    LOG_FILE="shared/storage/logs/laravel.log";
    if [[ TOTAL_COUNT -ge 3 ]] && [ -f $LOG_FILE ] ; then
        echo -e tail -f $LOG_FILE
        echo
        tail -f $LOG_FILE
    fi




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
}


# --------------------------------------------------------------------------------
#   phpbrew execute all fpm restart
# --------------------------------------------------------------------------------
jphpbrew_todo() {
    # if [ -z "$(command -v nginx)" ]
    # then
    #     echo 'nginx not exists'
    #     return
    # fi

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

#
# jurl -I
# jurl | jq .
#
function jurl() {

    if [ -z "$(command -v pygmentize)" ]
    then
        echo '-> sudo apt-get install python-pygments'
        return
    fi

    #
    if [ -z "$API" ]
        then
            echo '-> API=http://localhost:5050/api/v2/users?size=1'
            echo '-> API=http://localhost:5050/api/accounts/1/recent_lead_activities'
            return
    fi

    if [ -z "${Authorization}" ]
        then
            echo '-> Authorization="Bearer xxx.xxxxxx.xxx"'
            return
    fi

    # -sk   -> 靜默 + 跳過 SSL/TLS 證書驗證
    curl "$@" -s ${API} \
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
#   同 zsh 指令 rewrite
# --------------------------------------------------------------------------------
unalias git_current_branch 2>/dev/null
git_current_branch() {
    git rev-parse --abbrev-ref HEAD
}

# --------------------------------------------------------------------------------
#   go to phpmyadmin service
# --------------------------------------------------------------------------------
gotopma() {
    cd /fs/var/www/phpmyadmin-self-v3
    phpbrew use "$(phpbrew list | grep 'php-8\.4\.' | tail -n1 | awk '{print $NF}')"
    phpbrew list

    echo 'NOTE: '
    echo 'NOTE: php -S 127.0.0.1:7701 -t ./'
    echo 'NOTE: '
    echo 'php -S 127.0.0.1:7701 -t ./' | copy
}

gotocode() {
    cd /fs/var/www/tool/code-generator
    phpbrew use "$(phpbrew list | grep 'php-8\.4\.' | tail -n1 | awk '{print $NF}')"
    phpbrew list

    echo 'NOTE: '
    echo 'NOTE: php -S 127.0.0.1:7702 -t ./'
    echo 'NOTE: '
    echo 'php -S 127.0.0.1:7702 -t ./' | copy
}

gotoquerydata() {
    cd /fs/var/www/tool/query-data
    phpbrew use "$(phpbrew list | grep 'php-8\.4\.' | tail -n1 | awk '{print $NF}')"
    phpbrew list

    echo 'NOTE: '
    echo 'NOTE: php -S 127.0.0.1:7703 -t ./public/'
    echo 'NOTE: '
    echo 'php -S 127.0.0.1:7703 -t ./public/' | copy
}

# --------------------------------------------------------------------------------
#   convert
# --------------------------------------------------------------------------------

# > echo "T1234 feat   Welcome Message need to go" | slug
# t1234-feat-welcome-message-need-to-go
slug()
{
  cat | \
    sed -r 's/([a-z0-9]+)/\L\1/ig' | \
    sed -r 's/[\.\":]+//g' | \
    sed -e 's/\[//g' -e 's/\]//g' | \
    sed -r 's/[\.\,\_\ \-]+/-/g'
}

# --------------------------------------------------------------------------------
#   show file 檔案顯示
#
#   e.g.
#       se file.jpg
# --------------------------------------------------------------------------------
se() {
    local query="$1"
    local selected_file
    
    # 檢查輸入是否為現存的檔案 (相對路徑, 絕對路徑)
    if [[ -n "$query" && ( -f "$query" || -f "./$query" ) ]]; then
        # 如果檔案存在, 直接使用
        if [[ -f "$query" ]]; then
            selected_file="$query"
        else
            selected_file="./$query"
        fi
    elif [[ -n "$query" ]]; then
        # 如果有提供搜尋字串, 直接搜尋
        selected_file=$(find . -type f -name "*$query*" | fzf --query="$query")
    else
        # 沒有提供搜尋字串, 顯示所有檔案
        selected_file=$(find . -type f | fzf)
    fi
    
    if [[ -n "$selected_file" ]]; then
        local extension="${selected_file##*.}"
        local command=""
        
        case "$extension" in
            jpg|jpeg|tiff|tif|webp)
                # 顯示 EXIF 資訊
                echo "=== EXIF 資訊 ==="
                if command -v identify >/dev/null 2>&1; then
                    identify -verbose "$selected_file" | grep -E "(Geometry|Resolution|Colorspace|date:)" | head -n 8
                elif command -v exiftool >/dev/null 2>&1; then
                    exiftool "$selected_file" | grep -E "(File Size|Image Size|Camera|Date|GPS|Flash|ISO|Exposure|Focal)" | head -n 10
                else
                    echo "建議安裝: sudo apt install imagemagick"
                fi
                echo ""
                
                command="mpv --image-display-duration=inf \"$selected_file\""
                silent=true
                ;;
            png|gif|bmp|svg)
                command="mpv --image-display-duration=inf \"$selected_file\""
                silent=true
                ;;
            mp4|avi|mkv|mov|wmv|flv|webm|m4v)
                command="mpv \"$selected_file\""
                silent=true
                ;;
            mp3|wav|flac|aac|ogg|m4a)
                command="mpv \"$selected_file\""
                silent=true
                ;;
            pdf)
                command="evince \"$selected_file\""
                silent=true
                background=true
                ;;
            md|txt|log|conf|config|yml|yaml|json|xml)
                command="bat \"$selected_file\""
                silent=false
                ;;
            py|js|html|css|php|sh|bash|zsh)
                command="bat \"$selected_file\""
                silent=false
                ;;
            doc|docx|xls|xlsx|ppt|pptx)
                command="libreoffice \"$selected_file\""
                silent=true
                background=true
                ;;
            *)
                # 未知格式
                echo "==== file info ===="se
                echo "權限: $(ls -l "$selected_file" | awk '{print $1}')"
                echo "大小: $(ls -lh "$selected_file" | awk '{print $5}')"
                echo "類型: $(file "$selected_file")"
                
                command=""  # 不執行任何指令
                ;;
        esac
        
        # 根據需要修改指令
        if [[ "$silent" == true ]]; then
            command="$command >/dev/null 2>&1"
        fi
        if [[ "$background" == true ]]; then
            command="$command &"
        fi

        # 直接執行指令
        eval "$command"
    fi
}

# --------------------------------------------------------------------------------
#   快速進入 temp 目錄
# --------------------------------------------------------------------------------
jtemp () {
  cd /tmp
  cd "$(mktemp -d)"
  chmod -R 0700 .
  if [[ $# -eq 1 ]]; then
    \mkdir -p "$1"
    cd "$1"
    chmod -R 0700 .
  fi
  pwd
}

# --------------------------------------------------------------------------------
#   test only
# --------------------------------------------------------------------------------





# --------------------------------------------------------------------------------
#   end
# --------------------------------------------------------------------------------
echo `TZ=Asia/Taipei        date "+%Z [%z] %Y-%m-%d %T"`" - Asia/Taipei"
_strict_mode_end
