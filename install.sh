#!/bin/sh
## init
CONTINUE="Press [Enter] to continue…"
function pause() {
   read -p "$*"
}
function section() {
  echo "\n\n"
  echo "<========================================>"
  echo "$*"
}





section "Set machine root password in Directory Utility"
open /System/Library/CoreServices/Applications/Directory\ Utility.app
pause "Press [Enter] to continue…"







# Dotfiles
section "Installing dotfiles from https://github.com/christowiz/dotfiles.git"
DOT_TMP_DIR=~/.dot
mkdir $DOT_TMP_DIR
git clone https://github.com/christowiz/dotfiles.git $DOT_TMP_DIR
sh $DOT_TMP_DIR/bootstrap.sh
rm -rf $DOT_TMP_DIR









section "Install Homebrew, packages and casks"
# Check for Homebrew
if test ! $(which brew)
then
  echo "  Installing Homebrew for you."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" > /tmp/homebrew-install.log
fi

# Make sure we’re using the latest Homebrew.
echo "Updating Brew…"
brew update

# Upgrade any already-installed formulae.
echo "Upgrading Brew…"
brew upgrade

brew tap homebrew/core
brew tap mas-cli/tap
brew tap mas-cli/tap/mas
brew tap-pin mas-cli/tap
brew tap caskroom/cask
brew tap caskroom/fonts

echo "Installing Brew CLI Formulae"
brew install bash
brew install brew-cask-completion
brew install ccat
brew install git
brew install git-extras
brew install htop
brew install mas
brew install node
brew install libsass
brew install thefuck
brew install tmux
brew install watch
brew install wget
brew install zsh

# Core Functionality
echo "Installing Brew Cask Apps"
BREW_APPS=(
  alfred
  appcleaner
  bartender
  bettertouchtool
  brave-browser
  caffeine
  cd-to-iterm
  devdocs
  docker
  dropbox
  evernote
  expressvpn
  find-any-file
  firefox
  font-fira-code
  franz
  google-chrome
  google-chrome-canary
  homebrew/cask-drivers/wacom-tablet
  homebrew/cask-versions/firefox-developer-edition
  iterm2
  java
  kitematic
  liteswitch-x
  lingon-x
  macdown
  sketch
  slack
  sourcetree
  spectacle
  spotify
  sublime-text
  tmux
  transmit
  visual-studio-code
  zeplin
)

brew cask install java
brew cask install --appdir="~/Applications" ${BREW_APPS[@]}

# cleanup
echo "Cleanup Homebrew"
brew cleanup --verbose -s
rm -rf "$(brew --cache)"








# NODE
section "Install Node packages"
mkdir ~/.npm-packages

# Fix firewall when using `n` package
echo "Fix firewall when using `n` package"
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --remove $(which node)
sudo codesign --force --sign - $(which node)
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add $(which node)

echo "Installing global NPM packages"
NPM_APPS=(
  git-open
  list-scripts
  n
  npm@latest
  npm-check-updates
  npm-completion
  pure-prompt
  serve
  trash-cli
  yarn
)
npm install -g ${NPM_APPS[@]}

echo "Fixing `n` permissions"
sudo mkdir /usr/local/n
sudo chown -R $(whoami) $_

echo "Update Node version to latest"
n latest







# Get applications from App Store
section "Install App Store applications"

APPSTORE=(
  406056744 # Evernote
  942385494 # Memory Purge
  497799835 # Xcode
  409201541 # Pages
  409203825 # Numbers
  409183694 # Keynote
  #748212890 # Memory Cleaner
)

echo "Sign-in to App Store before continuing"
open /Applications/App\ Store.app
pause "Press any key to continue after signing into the Apple App Store... " -n1 -s
mas install ${APPSTORE[@]}
echo "\n"









# Get applications from Git repo
section "Install Spotify Menubar"
echo "Cloning binary from Github repo"
git clone https://github.com/christowiz/Spotify-Menubar-App.git
echo "Moving application only to ~/Applications"
mv ./Spotify-Menubar-App/Spotify\ Menubar.app/ ~/Applications
echo "Cleaning up…"
rm -rf ./Spotify-Menubar-App








## Set shell to zsh using `oh-my-zsh`
CUSTOM_ZSH=~/.oh-my-zsh/custom
section "Installing Oh-My-Zsh"
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

## ZSH Powerlevel9k Theme
## https://github.com/bhilburn/powerlevel9k
## https://medium.freecodecamp.org/jazz-up-your-zsh-terminal-in-seven-steps-a-visual-guide-e81a8fd59a38
## https://medium.com/@alex285/get-powerlevel9k-the-most-cool-linux-shell-ever-1c38516b0caa
echo "Cloning 'Powerlevel9k' theme"
git clone https://github.com/bhilburn/powerlevel9k.git $CUSTOM_ZSH/themes/powerlevel9k
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










section "Configure Applications"
open ~/Applications/Alfred\ 3.app
pause "Opening Alfred 3. ${CONTINUE}"
open ~/Applications/Bartender\ 3.app
pause "Opening Bartender 3. ${CONTINUE}"
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





# Sync applications
## VS Code
section "Install VS Code Sync extension"
code -nw
code -install-extension shan.code-settings-sync
echo "6d39e51d58474cb280a64f79f3cc0912" | tr -d '\n' | pbcopy
echo "6d39e51d58474cb280a64f79f3cc0912 -> copied to clipboard"
echo "Add Gist ID to Sync preferences"
echo "VS Code: ACCESS TOKEN REQUIRED"
pause "Press any key to continue…"











section "Configuring Sublime Text"
SUBLIME=~/Library/Application\ Support/Sublime\ Text\ 3
mkdir ~/Library/Application\ Support/Sublime\ Text\ 3
echo "Install Package Control"
wget https://packagecontrol.io/Package%20Control.sublime-package -P ~/Library/Application\ Support/Sublime\ Text\ 3/Installed\ Packages/
echo 'Sublime Text: After Dropbox is configured you can link "User" directory.'
echo 'Delete default Sublime Text User directory'
rm -rf ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User
echo 'Link Dropbox Sublime Text User directory to application support'
ln -s ~/Dropbox/Sublime\ Text\ 3/ ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User
# echo '{"installed_packages": ["Sync Settings"]}' > $SUBLIME/Packages/User/Package\ Control.sublime-settings
# echo "Sublime Text: ACCESS TOKEN REQUIRED"
# echo '{"access_token": "","auto_upgrade": true,"gist_id": "c10ea5a4adf5ebd0d445787ef306afa6"}' > $SUBLIME/Packages/User/SyncSettings.sublime-settings







echo "After applications are configured connect preferences in Dropbox for following apps:"
pause "Configure Alfred"
pause "Configure iTerm2"
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
