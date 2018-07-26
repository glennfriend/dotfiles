<?php

$BASH = __DIR__ . '/shell/ubuntu-shell/bash.sh';

echo <<<"EOD"

echo "# custom bash"            >> \$HOME/.bashrc
echo "source {$BASH}"           >> \$HOME/.bashrc
echo                            >> \$HOME/.bashrc


echo "# custom zsh"             >> \$HOME/.zshrc
echo "source {$BASH}"           >> \$HOME/.zshrc
echo                            >> \$HOME/.zshrc


EOD;
