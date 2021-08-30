<?php

/**
 *  須要安裝的 config
 */
return [
    [
        'desc'      => '[folder] all other config',
        'origin'    => 'shell/config',
        'to'        => 'config',
    ],
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
        'desc'      => '[folder] tmux plugins',
        'origin'    => 'shell/tmux-plugins',
        'to'        => '.tmux/plugins',
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
    [
        'desc'      => 'vscode-snippets',
        'origin'    => 'shell/vscode-snippets',
        'to'        => '.config/Code/User/snippets',
    ],
    [
        'desc'      => 'zsh-theme-myphp',
        'origin'    => 'shell/oh-my-zsh-tmeme/myphp.zsh-theme',
        'to'        => '.oh-my-zsh/themes/myphp.zsh-theme',
    ],
];
