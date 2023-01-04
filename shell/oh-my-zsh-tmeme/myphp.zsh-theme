#
# at 2021-04-27
#
# copy from ~/.oh-my-zsh/themes/crunch.zsh-theme
# copy to   ~/.oh-my-zsh/themes/myphp.zsh-theme
#
# vi ~/.zshrc
#
#   ZSH_THEME="myphp"
#
#

CRUNCH_BRACKET_COLOR="%{$fg[white]%}"
CRUNCH_TIME_COLOR="%{$fg[yellow]%}"
CRUNCH_RVM_COLOR="%{$fg[magenta]%}"
CRUNCH_DIR_COLOR="%{$fg[cyan]%}"
CRUNCH_GIT_BRANCH_COLOR="%{$fg[green]%}"
CRUNCH_GIT_CLEAN_COLOR="%{$fg[green]%}"
CRUNCH_GIT_DIRTY_COLOR="%{$fg[red]%}"

# These Git variables are used by the oh-my-zsh git_prompt_info helper:
ZSH_THEME_GIT_PROMPT_PREFIX="$CRUNCH_BRACKET_COLOR:$CRUNCH_GIT_BRANCH_COLOR"
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_CLEAN=" $CRUNCH_GIT_CLEAN_COLOR✓"
ZSH_THEME_GIT_PROMPT_DIRTY=" $CRUNCH_GIT_DIRTY_COLOR✗"

# Our elements:
CRUNCH_TIME_="$CRUNCH_BRACKET_COLOR{$CRUNCH_TIME_COLOR%T$CRUNCH_BRACKET_COLOR}%{$reset_color%}"
ZSH_THEME_RUBY_PROMPT_PREFIX="$CRUNCH_BRACKET_COLOR"["$CRUNCH_RVM_COLOR"
ZSH_THEME_RUBY_PROMPT_SUFFIX="$CRUNCH_BRACKET_COLOR"]"%{$reset_color%}"
# CRUNCH_RVM_='$(ruby_prompt_info)'
CRUNCH_DIR_="$CRUNCH_DIR_COLOR%~\$(git_prompt_info) "
CRUNCH_PROMPT="$CRUNCH_BRACKET_COLOR➭ "

# for php
local PHP_VERSION="php-"`php -r "echo substr(PHP_VERSION, 0, 3);"`
local PHPBREW_PHP_VERSION='$(phpbrew_current_php_version | sed -e "s/[-a-z][^0-9]*//g")'
local PHP_SHOW_=["%{$fg[blue]%}"phpbrew-${PHPBREW_PHP_VERSION}"%{$reset_color%}"]

# Put it all together!
PROMPT="$CRUNCH_TIME_$PHP_SHOW_$CRUNCH_DIR_$CRUNCH_PROMPT%{$reset_color%}"
