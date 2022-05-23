#!/bin/sh
## init
CONTINUE="Press [Enter] to continue…"
function pause() {
  read -p "$* $CONTINUE"
}

function action() {
  echo -e "--> $*"
}
function section() {
  echo -e "\n\n"
  echo "<================== $* =====================>"
  echo -e "\n"
}

function yesCheck() {
  read -p "$* (y/n): "
  if [ "$REPLY" = "y" ]; then
    return 0
  else
    return 1
  fi
}

function noCheck() {
  read -p "$* (y/n): "
  if [ "$REPLY" = "n" ]; then
    return 0
  else
    return 1
  fi
}

section "Installation setup"
echo -e "Before you begin the installation process make sure you own your hoe directory:"
echo -e "  sudo chown "
# Software Update
if [[ $OSTYPE != 'darwin'* ]]; then
  echo "This script is not supported on MacOS operating systems."
  exit 1
fi

section "Checking for available software updates"
if yesCheck "Do you want to run Software Update?"; then
  action "Updating software…"
  softwareupdate -l
fi

# Root pwd
section "Set up root password"
if yesCheck "Set machine root password in Directory Utility? "; then
  open -b com.apple.DirectoryUtility
fi

section "Dotfiles"
if yesCheck "Install dotfiles? "; then
  # Dotfiles
  pause "\nClone and install dotfiles from https://github.com/christowiz/dotfiles.git"
fi

# Install Hoemebrew
section "Install Homebrew, packages and casks"

# Check for Homebrew
if yesCheck "Install Homebrew? "; then
  if [ "$(command -v brew)" ]; then
    action "Clean current Homebrew install"
    rm -fr $(brew --repo homebrew/core)
  else
    action "Installing Homebrew for you."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
fi

echo -e "\nMake sure we’re using the latest Homebrew"
action "Updating Brew…"
brew update

echo -e "\nUpgrade any already-installed formulae"
action "Upgrading Brew…"
brew upgrade

action "Tapping Homebrew"
brew tap homebrew/core
brew tap buo/cask-upgrade
brew tap homebrew/cask
brew tap homebrew/cask-drivers
brew tap homebrew/cask-fonts
brew tap homebrew/cask-versions

BREW_APP_DIR=~/Applications
BREW_FORMULAES=(
  atuin
  awscli
  bash
  brew-cask-completion
  caddy
  ccat
  curl
  exa
  git
  git-extras
  go
  htop
  hub
  java
  lastpass-cli
  perl
  python
  spoof-mac
  telnet
  terminal-notifier
  thefuck
  tldr
  tmux
  tor
  tree
  watch
  wget
  zsh
)

# Core Functionality
BREW_CASK_APPS=(
  a-better-finder-rename
  alfred
  appcleaner
  app-tamer
  authy
  bartender
  brave-browser
  caffeine
  cyberduck
  devdocs
  dropbox
  homebrew/cask/docker
  eloston-chromium
  expressvpn
  fig
  figma
  find-any-file
  firefox
  firefox-developer-edition
  fluid
  font-fira-code
  font-hack-nerd-font
  franz
  gimp
  github
  google-chrome
  google-chrome-canary
  inkscape
  insomnia
  iterm2
  kitematic
  krita
  lastpass
  launchcontrol
  lingon-x
  macdown
  memory-cleaner
  microsoft-edge-dev
  mutespotifyads
  ngrok
  oversight
  runjs
  skype
  slack
  sourcetree
  spectacle
  spotify
  statusfy
  suspicious-package
  tableplus
  telegram
  tor-browser
  trilium-notes
  visual-studio-code
  # wacom-tablet
  xbar
  xquartz
)
NPM_APPS=(
  alfred-bundlephobia
  fkill-cli
  git-open
  list-scripts
  npkill
  npm@latest
  npm-check-updates
  npm-completion
  npm-name-cli
  pure-prompt
  react-devtools
  serve
  tldr
  trash-cli
)

action "Installing Brew CLI Formulae"
brew install ${BREW_FORMULAES[@]}

# Symlink Java
action "Configuring Java install"
sudo ln -sfn /opt/homebrew/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk

action "Installing Brew Cask Apps"
brew install --appdir="~/Applications" ${BREW_CASK_APPS[@]}

# cleanup
echo "Cleanup Homebrew"
brew cleanup --verbose -s
rm -rf "$(brew --cache)"

# NODE
section "Node.js"

echo "Choose Node.js package manager:"
PKG_MGRS=(asdf n nvm volta)
select pkg in "${PKG_MGRS[@]}"; do
  case $pkg in
  "asdf" | 1)
    brew install asdf gpg
    asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
    break
    ;;
  "n" | 2)
    brew install n
    n lts

    action "Fixing $(n) permissions"
    sudo mkdir /usr/local/n
    sudo chown -R $(whoami) $_

    action "Fix firewall when using $(n) package"
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --remove $(which node)
    sudo codesign --force --sign - $(which node)
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add $(which node)
    break
    ;;
  "nvm" | 3)
    wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

    action "Setting up nvm"
    echo 'export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"\n[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >>~/.zshrc
    source ~/.nvm/nvm.sh
    # source ~/.zprofile

    nvm install node
    break
    ;;
  "volta" | 4)
    brew install volta
    volta install node
    break
    ;;
  *)
    echo "Wrong selection: Select any number from 1-$#"
    break
    ;;
  esac
done

if yesCheck "Would you like to install Yarn?? "; then
  brew install yarn
fi

action "Installing global NPM packages"
npm install -g ${NPM_APPS[@]}

# Get applications from App Store
# section "Install App Store applications"

# APPSTORE=(
#   942385494 # Memory Purge
#   497799835 # Xcode
#   748212890 # Memory Cleaner
# )

# echo "Sign-in to App Store before continuing"
# open /System/Applications/App\ Store.app
# pause "Press any key to continue after signing into the Apple App Store... " -n1 -s
# mas install ${APPSTORE[@]}
# echo "\n"

## Set shell to zsh using `oh-my-zsh`
section "Installing Oh-My-Zsh"
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
CUSTOM_ZSH=~/.oh-my-zsh/custom

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
POWERLINE_FONTS="https://github.com/powerline/fonts.git"

action "Installing Powerline fronts from $POWERLINE_FONTS"
FONT_TMP_DIR=".tmp"
mkdir $FONT_TMP_DIR
git clone $POWERLINE_FONTS ./$FONT_TMP_DIR
sh $FONT_TMP_DIR/install.sh
rm -rf $FONT_TMP_DIR

## Switch shell to ZSH
action "Add Brew-installed shells to /etc/shell"
sudo dscl . -create /Users/$USER UserShell $(which bash)
sudo dscl . -create /Users/$USER UserShell $(which zsh)

section "Check shell type"
if [[ $(echo $0) != '/bin/zsh'* ]]; then
  if yesCheck "Would you like to switch to ZSH? (y/n)? "; then
    action "Changeing shell to ZSH"
    chsh -s $(which zsh)
  fi
fi

ecactionho "xcode-select install/switch"
sudo xcode-select --install
sudo xcode-select --switch /Library/Developer/CommandLineTools/

# iTerm 2 color schemes
action "Installing iTerm2 Color Schemes from https://github.com/mbadolato/iTerm2-Color-Schemes.git"
git clone https://github.com/mbadolato/iTerm2-Color-Schemes.git ~/.iterm2/iTerm2-Color-Schemes

# System Preferences
section "Setting System preferences"

echo "Show hidden files"
defaults write com.apple.finder AppleShowAllFiles YES

echo "Show path in Finder title bar"
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

## Restart Finder
action "Restarting Finder"
killall Finder

section "Manual application install"

if yesCheck "Would you like to install Quiver?"; then
  pause "Download Quiver from https://yliansoft.com and drag it to your Applications folder."
  open "https://yliansoft.com"
fi

# Install Prey
if yesCheck "Would you like to install Prey?"; then
  Open https://preyproject.com
  pause
fi

section "Configure Applications"
action "Configure Dropbox for synced application preferences"
open $BREW_APP_DIR/Dropbox.app
pause "Opening Dropbox. ${CONTINUE}"

open $BREW_APP_DIR/Alfred\ 4.app
pause "Opening Alfred 4. ${CONTINUE}"
open $BREW_APP_DIR/Bartender\ 3.app
pause "Opening Bartender 4. ${CONTINUE}"
open $BREW_APP_DIR/Caffeine.app
pause "Opening Caffeine. ${CONTINUE}"
open $BREW_APP_DIR/Franz.app
pause "Opening Franz. ${CONTINUE}"
open $BREW_APP_DIR/Spectacle.app
pause "Opening Spectacle. ${CONTINUE}"
open $BREW_APP_DIR/Spotify.app
pause "Opening Spotify. ${CONTINUE}"

echo "After applications are configured connect preferences in Dropbox for following apps:"
pause "Configure Alfred"
pause "Configure iTerm2"

section "Additional security: https://objective-see.com/products.html"

unset APPSTORE
unset BREW_APP_DIR
unset BREW_CASK_APPS
unset BREW_FORMULAES
unset CONTINUE
unset CUSTOM_ZSH
unset FONT_TMP_DIR
unset NPM_APPS
unset pause
unset PKG_MGRS
unset POWERLINE_FONTS
unset section
unset SUBLIME

section "Applications requiring system restart"
if yesCheck "Would you like to download the 6.3.41-2 Wacom Tablet driver? (This version supports normal pan/scroll functionality)"; then
  action "Downloading tablet driver from https://cdn.wacom.com/"
  curl -L -o ~/Downloads/WacomTablet_6.3.41-2.dmg https://cdn.wacom.com/u/productsupport/drivers/mac/professional/WacomTablet_6.3.41-2.dmg
  echo "Driver installed to ~/Downloads/WacomTablet_6.3.41-2.dmg"
  if yesCheck "Would you like to install the driver now?  This will require a system restart"; then
    action "Installing Wacom Tablet driver"
    sudo installer -pkg ~/Downloads/WacomTablet_6.3.41-2.dmg -target /
    echo "Driver installed"
  else
    echo "Install manually when ready"
    open ~/Downloads
  fi
fi
