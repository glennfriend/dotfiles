<?php

// --------------------------------------------------------------------------------
// step 1
// --------------------------------------------------------------------------------
output('這個程式將安裝並且覆蓋 symlink 到你指定的使用者目錄, 例如 /home/zelda');
output('請輸您的名稱, 例如 zelda');
$input = input();
if (!$input) {
    output('沒有執行任何指令');
    exit;
}

$installFolder = '/home/' . $input;
if (!is_dir($installFolder)) {
    output('這個目錄不存在');
    exit;
}

// --------------------------------------------------------------------------------
// step 2
// 確認專案裡面的檔案有沒有問題
// --------------------------------------------------------------------------------
$erororMessages = '';
foreach (getMapping() as $config) {
    $originFile = getDir() . '/' . $config['origin'];
    if (!file_exists($originFile)) {
        $erororMessages .= '檔案不存在: ' . $originFile. "\n";
    }
}
if ($erororMessages) {
    output('原始程式發生錯誤!');
    output($erororMessages);
    exit;
}

// --------------------------------------------------------------------------------
// step 3
// 讓使用者確認要覆蓋的檔案
// --------------------------------------------------------------------------------
$allowMessage = '';
$denyMessage = '';
foreach (getMapping() as $config) {
    $toFile = $installFolder . '/' . $config['to'];
    if (file_exists($toFile)) {
        $denyMessage .= '    ' . $toFile. "\n";
    }
    else {
        $allowMessage .= '    ' . $toFile. "\n";
    }
}

output('以下檔案 "不存在", 會建立 symlink');
output($allowMessage);
output();
output('以下檔案 "已存在", 將不會被影響');
output($denyMessage);
output();

if (!$allowMessage) {
    output('因為沒有檔案會受到影響, 所以程式結束!');
    exit;
}
output('如果您確認沒問題, 請輸入 "yes", 即將會執行所有的指令:');

// --------------------------------------------------------------------------------
// step 4
// 執行指令, 建立 symlink 並覆蓋原有的檔案 (具有破壞性)
// --------------------------------------------------------------------------------
if ('yes' !== input()) {
    output('沒有執行任何指令');
    exit;
}

foreach (getMapping() as $config) {
    $originFile = getDir() . '/' . $config['origin'];
    $toFile     = $installFolder . '/' . $config['to'];
    if (file_exists($toFile)) {
        continue;
    }
    symlink($originFile, $toFile);
}

output('已執行!');
exit;










/**
 *  取得要安裝的 config
 */
function getMapping()
{
    return [
        [
            'desc'      => 'gitconfig',
            'origin'    => 'shell/git/gitconfig.txt',
            'to'        => '.gitconfig',
        ],
        [
            'desc'      => 'bashrc',
            'origin'    => 'shell/sh/bashrc.txt',
            'to'        => '.bashrc',
        ],
        [
            'desc'      => 'tmux config',
            'origin'    => 'shell/tmux/tmux.conf',
            'to'        => '.tmux.conf',
        ],
    ];
}

function getDir()
{
    return __DIR__;
}

/**
 * 取得使用者輸入的資料
 */
function input()
{
    return trim(fgets(STDIN));
}

/**
 * 顯示內容
 */
function output($content='')
{
    echo $content . "\n";
}

/**
 * 執行並取得結果
 */
function execute($shell)
{
    return exec($shell);
}