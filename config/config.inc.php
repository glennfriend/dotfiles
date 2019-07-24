<?php

/**
 *  須要安裝的 config
 */
return [
    [
        'desc'      => 'gitconfig',
        'origin'    => 'shell/git/gitconfig.txt',
        'to'        => '.gitconfig',
    ],
    [
        'desc'      => 'tmux config',
        'origin'    => 'shell/tmux/tmux.conf',
        'to'        => '.tmux.conf',
    ],
    [
        'desc'      => 'tmuxinator (mux) config',
        'origin'    => 'shell/tmuxinator',
        'to'        => '.tmuxinator',
    ],
    [
        'desc'      => 'vim config',
        'origin'    => 'shell/vim/vimrc.txt',
        'to'        => '.vimrc',
    ],
    [
        'desc'      => 'vscode',
        'origin'    => 'shell/vscode/settings.json',
        'to'        => '.config/Code/User/settings.json',
    ],
];
