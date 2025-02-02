#!/bin/bash

source ./utils.sh

install_ohmyzsh() {
  sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
  local CUSTOM_ZSH=~/.oh-my-zsh/custom

  ## ZSH Powerlevel10k Theme
  ## https://github.com/romkatv/powerlevel10k
  ## https://jwendl.net/2019/12/07/wsl-powerlevel10k/
  action "Cloning 'Powerlevel10k' theme"
  git clone https://github.com/romkatv/powerlevel10k.git $CUSTOM_ZSH/themes/powerlevel10k
  action "Cloning 'zsh-autosuggestions' plugin"
  git clone https://github.com/zsh-users/zsh-autosuggestions $CUSTOM_ZSH/plugins/zsh-autosuggestions
  action "Cloning 'zsh-syntax-highlighting' plugin"
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $CUSTOM_ZSH/plugins/zsh-syntax-highlighting

  ## Install font for Powerlevel9k theme
  local POWERLINE_FONTS="https://github.com/powerline/fonts.git"

  action "Installing Powerline fronts from $POWERLINE_FONTS"
  local FONT_TMP_DIR=".tmp"
  mkdir $FONT_TMP_DIR
  git clone $POWERLINE_FONTS ./$FONT_TMP_DIR
  sh $FONT_TMP_DIR/install.sh
  rm -rf $FONT_TMP_DIR

  ## Switch shell to ZSH
  action "Add Brew-installed shells to /etc/shell"
  sudo dscl . -create /Users/"$USER" UserShell $(which bash)
  sudo dscl . -create /Users/"$USER" UserShell $(which zsh)

  section "Check shell type"
  if [[ $0 != '/bin/zsh'* ]]; then
    if yesCheck "Would you like to switch to ZSH? (y/n)? "; then
      action "Changeing shell to ZSH"
      chsh -s $(which zsh)
    fi
  fi

  unset CUSTOM_ZSH
  unset POWERLINE_FONTS
  unset FONT_TMP_DIR
}
