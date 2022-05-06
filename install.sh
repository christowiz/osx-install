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
if [[ $OSTYPE == 'darwin'* ]]; then
  section "Checking for available software updates"
  softwareupdate -l

  # Root pwd
  section "Set up root password"
  yesCheck "Set machine root password in Directory Utility (y/n)? " && open -b com.apple.systempreferences /System/Library/PreferencePanes/SoftwareUpdate.prefPane
fi

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

# Check for Homebrew
if test ! $(which brew); then
  action "Clean current Homebrew install"
  rm -fr $(brew --repo homebrew/core)
else
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

BREW_APP_DIR=~/Applications
BREW_APPS=(
  atuin
  awscli
  bash
  brew-cask-completion
  caddy
  ccat
  cmake
  curl
  exa
  git
  git-extras
  go
  heroku
  heroku-node
  htop
  hub
  java
  lastpass-cli
  libsass
  mas
  mas-cli/tap/mas
  nvm
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
  charles
  cyberduck
  devdocs
  diffmerge
  dropbox
  docker
  eloston-chromium
  evernote
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
  google-chrome
  google-chrome-canary
  firefox
  firefox-developer-edition
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
  prey
  runjs
  skype
  slack
  sonos
  sourcetree
  spectacle
  spotify
  statusfy
  suspicious-package
  tableplus
  telegram
  tor-browser
  trilium-notes
  vectr
  visual-studio-code
  wacom-tablet
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

echo "Choose Node.js package manager:"
select pkg in asdf n nvn volta; do
  if [ 1 -le "$pkg" ] && [ "$pkg" -le $# ]; then
    # if [ "$pkg" = "n" ]; then
    #   NPM_APPS=(${NPM_APPS[@]} "n")
    # else
    #   BREW_APPS=(${BREW_APPS[@]} "nvm")
    # fi
    # break
    case $pkg in
    # Two case values are declared here for matching
    "asdf")
      BREW_APPS=(${BREW_APPS[@]} "asdf", "gpg")
      ;;
      # Three case values are declared here for matching
    "n")
      BREW_APPS=(${BREW_APPS[@]} "n")
      ;;
      # Three case values are declared here for matching
    "nvm")
      BREW_APPS=(${BREW_APPS[@]} "nvm")
      ;;
    "volta")
      BREW_APPS=(${BREW_APPS[@]} "volta")
      ;;
    # Matching with invalid data
    *)
      echo "Invalid entry."
      break
      ;;
    esac

  else
    echo "Wrong selection: Select any number from 1-$#"
  fi
done

if yesCheck "Would you like to install Yarn? (y/n)? "; then
  BREW_APPS=(${BREW_APPS[@]} "yarn")
fi

action "Installing Brew CLI Formulae"
brew install ${BREW_APPS[@]}

action "Installing Brew Cask Apps"
brew install --appdir="~/Applications" ${BREW_CASK_APPS[@]}

# cleanup
echo "Cleanup Homebrew"
brew cleanup --verbose -s
rm -rf "$(brew --cache)"

# NODE
section "Install Node packages"

action "Installing Node.js"
case $pkg in
# Two case values are declared here for matching
"asdf")
  asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
  ;;
  # Three case values are declared here for matching
"n")
  n lts

  action "Fixing $(n) permissions"
  sudo mkdir /usr/local/n
  sudo chown -R $(whoami) $_

  action "Fix firewall when using $(n) package"
  sudo /usr/libexec/ApplicationFirewall/socketfilterfw --remove $(which node)
  sudo codesign --force --sign - $(which node)
  sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add $(which node)
  ;;
  # Three case values are declared here for matching
"nvm")
  if command -v nvm | grep -q 'command not found'; then
    source ~/.zshrc
    nvm install node
  fi
  ;;
"volta")
  volta install node
  ;;
esac

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
CUSTOM_ZSH=~/.oh-my-zsh/custom
section "Installing Oh-My-Zsh"
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

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

action "Change shell to ZSH"
chsh -s $(which zsh)

ecactionho "xcode-select install/switch"
sudo xcode-select --install
sudo xcode-select --switch /Library/Developer/CommandLineTools/

# iTerm 2 color schemes
action "Installing iTerm2 Color Schemes from https://github.com/mbadolato/iTerm2-Color-Schemes.git"
git clone https://github.com/mbadolato/iTerm2-Color-Schemes.git ~/.iterm2

# System Preferences
section "Setting System preferences"

echo "Show hidden files"
defaults write com.apple.finder AppleShowAllFiles YES

echo "Show path in Finder title bar"
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

## Restart Finder
action "Restarting Finder"
killall Finder

# Install Prey
section "Install Prey tracking app"
Open https://preyproject.com
pause "Press [ENTER] when completed "

section "Configure Applications"
open $BREW_APP_DIR/Alfred\ 4.app
pause "Opening Alfred 4. ${CONTINUE}"
open $BREW_APP_DIR/Bartender\ 3.app
pause "Opening Bartender 4. ${CONTINUE}"
open $BREW_APP_DIR/Caffeine.app
pause "Opening Caffeine. ${CONTINUE}"
open $BREW_APP_DIR/Dropbox.app
pause "Opening Dropbox. ${CONTINUE}"
open $BREW_APP_DIR/Franz.app
pause "Opening Franz. ${CONTINUE}"
open $BREW_APP_DIR/Spectacle.app
pause "Opening Spectacle. ${CONTINUE}"
open $BREW_APP_DIR/Spotify.app
pause "Opening Spotify Menubar. ${CONTINUE}"

echo "After applications are configured connect preferences in Dropbox for following apps:"
pause "Configure Alfred"
pause "Configure iTerm2"

section "Additional security: https://objective-see.com/products.html"

unset CONTINUE
unset pause
unset pkg
unset section
unset DOT_TMP_DIR
unset BREW_APP_DIR
unset BREW_CASK_APPS
unset NPM_APPS
unset APPSTORE
unset SUBLIME
unset CUSTOM_ZSH
unset POWERLINE_FONTS
unset FONT_TMP_DIR
