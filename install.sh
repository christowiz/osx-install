#!/bin/sh
## init
CONTINUE="Press [Enter] to continue…"
function pause() {
  read -p "$*"
}

function action() {
  echo "--> $*"
}
function section() {
  echo "\n\n"
  echo "<================== $* =====================>"
  echo "\n"
}

function yesCheck() {
  read -p "$*"
  if [ "$REPLY" = "y" ]; then
    return 0
  else
    return 1
  fi
}

function noCheck() {
  read -p "$*"
  if [ "$REPLY" = "n" ]; then
    return 0
  else
    return 1
  fi
}

# Software Update
section "Checking for available software updates"
softwareupdate -l

# Root pwd
section "Set up root password"
yesCheck "Set machine root password in Directory Utility (y/n)? " && open -b com.apple.systempreferences /System/Library/PreferencePanes/SoftwareUpdate.prefPane

# Dotfiles
section "Installing dotfiles from https://github.com/christowiz/dotfiles.git"
DOT_TMP_DIR=~/.dot
sudo mkdir $DOT_TMP_DIR
sudo chmod 777 $DOT_TMP_DIR
git clone https://github.com/christowiz/dotfiles.git $DOT_TMP_DIR
sh $DOT_TMP_DIR/bootstrap.sh
rm -rf $DOT_TMP_DIR

# Install Hoemebrew
section "Install Homebrew, packages and casks"

action "Clean current Homebrew install"
rm -fr $(brew --repo homebrew/core)

# Check for Homebrew
if test ! $(which brew); then
  action "Installing Homebrew for you."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "Make sure we’re using the latest Homebrew"
action "Updating Brew…"
brew update

echo "Upgrade any already-installed formulae"
action "Upgrading Brew…"
brew upgrade

action "Tapping Homebrew"
brew tap homebrew/core
brew tap buo/cask-upgrade
brew tap mas-cli/tap
Brew tap homebrew/cask-fonts
brew tap caskroom/cask
brew tap caskroom/fonts

action "Installing Brew CLI Formulae"
brew install atuin
brew install bash
brew install brew-cask-completion
brew install caddy
brew install ccat
brew install git
brew install git-extras
brew install htop
brew install hub
brew install java
brew install libsass
brew install mas
Brew install mas-cli/tap/mas
# brew install node
#// Installing nvm, perl, python, thefuck, and tmux.
brew install nvm
brew install perl
brew install python
brew install thefuck
brew install tmux
brew install tor
brew install watch
brew install wget
brew install zsh

# Core Functionality
echo "Installing Brew Cask Apps"
BREW_APPS=(
  a-better-finder-rename
  alfred
  appcleaner
  app-tamer
  bartender
  bettertouchtool
  brave-browser
  caffeine
  charles
  cyberduck
  devdocs
  diffmerge
  dropbox
  evernote
  expressvpn
  find-any-file
  firefox
  firefox-developer-edition
  fluid
  font-fira-code
  franz
  gimp
  google-chrome
  google-chrome-canary
  haptic-touch-bar
  hazeover
  homebrew/cask/docker
  homebrew/cask-versions/firefox-developer-edition
  inkscape
  iterm2
  kdiff3
  kitematic
  krita
  lingon-x
  macdown
  memory-cleaner
  microsoft-edge-dev
  mutespotifyads
  ngrok
  pock
  prey
  qlcolorcode
  runjs
  sketch
  skype
  slack
  sonos
  sourcetree
  spectacle
  spotify
  statusfy
  suspicious-package
  tableplus
  tor-browser
  touchswitcher
  transmit
  vectr
  visual-studio-code
  wacom-tablet
  xquartz
)

brew install --appdir="~/Applications" ${BREW_APPS[@]}

# cleanup
echo "Cleanup Homebrew"
brew cleanup --verbose -s
rm -rf "$(brew --cache)"

# NODE
section "Install Node packages"
# mkdir ~/.npm-packages

if yesCheck "Are you using 'n' for Node? (y/n)? "; then
  action "Fix firewall when using $(n) package"
  sudo /usr/libexec/ApplicationFirewall/socketfilterfw --remove $(which node)
  sudo codesign --force --sign - $(which node)
  sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add $(which node)
fi
if yesCheck "Are you using NVM? (y/n)? "; then


action "Installing global NPM packages"
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
  #yarn
)

if $NPKG; then
  NPM_APPS=("${NPM_APPS[@]}" "n")
fi

npm install -g ${NPM_APPS[@]}

yesCheck "Would you like to install Yarn? (y/n)? " && corepack enable &&

echo "Fixing $(n) permissions"
sudo mkdir /usr/local/n
sudo chown -R $(whoami) $_

echo "Update Node version to latest"
n latest

# Get applications from App Store
section "Install App Store applications"

APPSTORE=(
  942385494 # Memory Purge
  497799835 # Xcode
  748212890 # Memory Cleaner
)

echo "Sign-in to App Store before continuing"
open /System/Applications/App\ Store.app
pause "Press any key to continue after signing into the Apple App Store... " -n1 -s
mas install ${APPSTORE[@]}
echo "\n"

## Set shell to zsh using `oh-my-zsh`
CUSTOM_ZSH=~/.oh-my-zsh/custom
section "Installing Oh-My-Zsh"
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

## ZSH Powerlevel10k Theme
## https://github.com/romkatv/powerlevel10k
## https://jwendl.net/2019/12/07/wsl-powerlevel10k/
echo "Cloning 'Powerlevel10k' theme"
git clone https://github.com/romkatv/powerlevel10k.git $CUSTOM_ZSH/themes/powerlevel10k
echo "Cloning 'zsh-autosuggestions' plugin"
git clone https://github.com/zsh-users/zsh-autosuggestions $CUSTOM_ZSH/plugins/zsh-autosuggestions
echo "Cloning 'zsh-syntax-highlighting' plugin"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $CUSTOM_ZSH/plugins/zsh-syntax-highlighting

## Install font for Powerlevel9k theme
POWERLINE_FONTS="https://github.com/powerline/fonts.git"
echo "Installing Powerline fronts from $POWERLINE_FONTS"
FONT_TMP_DIR=".tmp"
mkdir $FONT_TMP_DIR
git clone $POWERLINE_FONTS ./$FONT_TMP_DIR
sh $FONT_TMP_DIR/install.sh
rm -rf $FONT_TMP_DIR

## Switch shell to ZSH
echo "Add Brew-installed shells to /etc/shell"
sudo dscl . -create /Users/$USER UserShell $(which bash)
sudo dscl . -create /Users/$USER UserShell $(which zsh)
echo "Change shell to ZSH"
chsh -s $(which zsh)
echo "xcode-select install/switch"
sudo xcode-select --install
sudo xcode-select --switch /Library/Developer/CommandLineTools/

# iTerm 2 color schemes
echo "Installing iTerm2 Color Schemes from https://github.com/mbadolato/iTerm2-Color-Schemes.git"
git clone https://github.com/mbadolato/iTerm2-Color-Schemes.git ~/.iterm2

# System Preferences
section "Setting System preferences"

echo "Show hidden files"
defaults write com.apple.finder AppleShowAllFiles YES

echo "Show path in Finder title bar"
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

## Restart Finder
echo "Restarting Finder"
killall Finder

# Install Prey
section "Install Prey tracking app"
Open https://preyproject.com
pause "Press [ENTER] when completed "

section "Configure Applications"
open ~/Applications/Alfred\ 4.app
pause "Opening Alfred 4. ${CONTINUE}"
open ~/Applications/Bartender\ 3.app
pause "Opening Bartender 4. ${CONTINUE}"
open ~/Applications/Caffeine.app
pause "Opening Caffeine. ${CONTINUE}"
open ~/Applications/Dropbox.app
pause "Opening Dropbox. ${CONTINUE}"
open ~/Applications/Franz.app
pause "Opening Franz. ${CONTINUE}"
open ~/Library/PreferencePanes/LiteSwitch\ X.app
pause "Opening LiteSwitch X. ${CONTINUE}"
open ~/Applications/Spectacle.app
pause "Opening Spectacle. ${CONTINUE}"
open ~/Applications/Spotify\ Menubar.app
pause "Opening Spotify Menubar. ${CONTINUE}"

echo "After applications are configured connect preferences in Dropbox for following apps:"
pause "Configure Alfred"
pause "Configure iTerm2"

section "Additional security: https://objective-see.com/products.html"

unset CONTINUE
unset pause
unset section
unset DOT_TMP_DIR
unset BREW_APPS
unset NPM_APPS
unset APPSTORE
unset SUBLIME
unset CUSTOM_ZSH
unset POWERLINE_FONTS
unset FONT_TMP_DIR
