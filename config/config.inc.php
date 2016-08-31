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
        'desc'      => 'bashrc',
        'origin'    => 'shell/sh/bashrc.txt',
        'to'        => '.bashrc',
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
];
