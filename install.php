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
$filesMessage = '';
foreach (getMapping() as $config) {
    $toFile = $installFolder . '/' . $config['to'];
    if (file_exists($toFile)) {
        $filesMessage .= '檔案已存在: ' . $toFile. "\n";
    }
    else {
        $filesMessage .= '檔案不存在: ' . $toFile. "\n";
    }
}
if (!$filesMessage) {
    output('沒有執行任何指令 (2)');
    exit;
}


output('請檢查以下所有即將會被變更檔案');
output($filesMessage);
output();
output('如果您確認沒問題, 請輸入 "yes", 即將會執行所有的指令:');

// --------------------------------------------------------------------------------
// step 4
// 執行指令, 建立 symlink
// --------------------------------------------------------------------------------
if ('yes' !== input()) {
    output('沒有執行任何指令');
    exit;
}

//symlink


output('go go go !');
exit;









function getDir()
{
    return __DIR__;
}

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
    ];
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