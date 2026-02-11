#!/usr/bin/env bash
#
# curl -O https://raw.githubusercontent.com/glennfriend/dotfiles/master/shell/info/linux-info.sh
#

if ! sudo -v > /dev/null 2>&1; then
    echo "You do not have sudo privileges. Exiting."
    exit 1
fi

# ================================================================================
# helper
# ================================================================================
run() {
    local func=$1
    local title=${2:-$1}    # 如果沒有第二個參數, 就用第一個參數的名字

    echo "------ $title ------"
    "$func"
    echo ; echo
}

# ================================================================================
# function
# ================================================================================
current_times() {
    echo "  "`TZ=America/Los_Angeles date "+%Z [%z] %Y-%m-%d %T"`"  LA     "
    echo "  "`TZ=UTC                 date "+%Z [%z] %Y-%m-%d %T"`"  UTC    "
    echo "  "`TZ=Asia/Taipei         date "+%Z [%z] %Y-%m-%d %T"`"  Taipei "
}

hostname() {
    command hostname
}

system_info_cmd() {
    cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2
    uname -r
}

nginx() {
    local cmd='ls -la /etc/nginx/sites-available/'
    echo "> ${cmd}" ; ${cmd}
    echo
    echo "Nginx 監聽的域名和連接埠:"
    grep -r "server_name\|listen" /etc/nginx/sites-enabled/ 2>/dev/null | grep -v "#"
}

resource_usage() {
    echo "CPU 核心數: $(nproc)"
    echo ""
    echo "Memory:"
    free -h
    echo ""
    echo "Disk 使用:"
    df -h | grep -E "^/dev|Filesystem"
}

ports_in_use() {
    echo '所有監聽的連接埠:'
    echo
    echo '> sudo netstat -tulpn | grep LISTEN | sort -k4'
            sudo netstat -tulpn | grep LISTEN | sort -k4
    echo
    echo '> sudo ss -tulpn | grep LISTEN | sort'
            sudo ss -tulpn | grep LISTEN | sort
}

running_processes() {
    echo "=== Node.js 進程 ==="
    ps aux | grep -E "[n]ode|[n]pm|[y]arn" | head -n 10
    echo ""
    echo "=== PHP 進程 ==="
    ps aux | grep -E "[p]hp|[p]hp-fpm" | head -n 10
    echo ""
    echo "=== Web Server ==="
    ps aux | grep -E "[n]ginx|[a]pache|[c]addy" | head -n 5
    echo ""
    echo "=== MySQL/MariaDB ==="
    ps aux | grep -E "[m]ysql|[m]ariadb|[p]ostgres" | head -n 5
    echo ""
    echo "=== Redis ==="
    ps aux | grep "[r]edis" | head -n 5
    echo ""
    echo "=== Elasticsearch ==="
    ps aux | grep "[e]lasticsearch" | head -n 5
}

systemd_services() {
    local cmd="systemctl list-units --type=service --state=running --no-pager"
    echo "> ${cmd}" ; ${cmd}
    
}

docker_status() {
    if command -v docker &> /dev/null; then
        echo "Docker 已安裝: $(docker --version)"
        echo ""
        echo "運行中的容器:"
        docker ps 2>/dev/null || echo "無權限或 Docker 未運行"
    else
        echo "Docker 未安裝"
    fi
}

project_directories() {
    echo "> ls -la /var/www/"
            ls -la /var/www/ 2>/dev/null || echo "/var/www/ 不存在"
    echo
    echo "> ls -la /opt/www/"
            ls -la /opt/www/ 2>/dev/null || echo "/opt/www/ 不存在"
    echo
    echo "> ls -la /home/"
            ls -la /home/ 2>/dev/null
    echo
    echo "=== .env 檔案位置 ==="
    find /var/www /opt/www /home -maxdepth 3 -name ".env" -type f 2>/dev/null | head -n 10
}

env_file_content() {
    echo "尋找 .env 關鍵配置 (去除敏感資訊):"
    local env_files=$(find /var/www /opt/www /home -maxdepth 3 -name ".env" -type f 2>/dev/null | head -n 3)

    if [ -z "$env_files" ]; then
        echo "未找到 .env 檔案"
        return
    fi

    for env_file in $env_files; do
        echo
        echo "[$env_file]"
        cat "$env_file" 2>/dev/null | grep -E "^(APP_|DB_|REDIS_|QUEUE_|PORT|URL|ELASTICSEARCH)" | grep -v "PASSWORD\|SECRET\|KEY" || echo "無權限讀取"
    done
}

pm2_status() {
    if command -v pm2 &> /dev/null; then
        echo "PM2 已安裝"
        echo ""
        su - $(ls /home | head -n 1) -c "pm2 list" 2>/dev/null || echo "無法取得 PM2 狀態"
    else
        echo "PM2 未安裝"
    fi
}

# ================================================================================
# perform
# ================================================================================
clear

run current_times
run hostname            "主機名稱"
run system_info_cmd     "系統資訊"
run resource_usage      "資源使用情況"
run ports_in_use        "連接埠使用情況"
run running_processes   "運行中的服務進程"
run systemd_services
run docker_status
run project_directories "專案目錄結構"
run nginx
run env_file_content
run pm2_status
