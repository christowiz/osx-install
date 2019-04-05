#!/bin/sh
## init
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
DOT_TMP_DIR=".dot"
mkdir $DOT_TMP_DIR
git clone https://github.com/christowiz/dotfiles.git ./$DOT_TMP_DIR
./$DOT_TMP_DIR/./bootstrap.sh
rm -rf $DOT_TMP_DIR









section "Install Homebrew, packages and casks"
# Check for Homebrew
if test ! $(which brew)
then
  echo "  Installing Homebrew for you."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" > /tmp/homebrew-install.log
fi

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

brew tap homebrew/core
brew tap mas-cli/tap
brew tap-pin mas-cli/tap
brew tap caskroom/cask
brew tap caskroom/fonts

echo "Installing Brew CLI Formulae"
brew install bash
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
  bartender
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


echo "Update Node version to latest"
n install latest

echo "Installing global NPM packages"
NPM_APPS=(
  git-open
  list-scripts
  n
  npm@latest
  npm-check-updates
  npm-completion
  repo
  serve
  trash-cli
)
npm install -g ${NPM_APPS[@]}

echo "Fixing `n` permissions"
sudo mkdir /usr/local/n
sudo chown -R $(whoami) $_








# Get applications from App Store
section "Install App Store applications"

APPSTORE=(
  406056744 # Evernote
  942385494 # Memory Purge
  497799835 # Xcode
  409201541 # Pages
  409203825 # Numbers
  409183694 # Keynote
)

echo "Sign-in to App Store before continuing"
open /Applications/App\ Store.app
pause "Press any key to continue after signing into the Apple App Store... " -n1 -s
mas install ${APPSTORE[@]}
echo "\n"







# Get applications from Git repo
section "Install Spotify Menubar"
npx repo download christowiz/Spotify-Menubar-App 'Spotify Menubar.app' ~/Applications/Spotify\ Menubar.app






# Sync applications
## VS Code
section "Install VS Code Sync extension"
code -nw
code -install-extension shan.code-settings-sync
echo "6d39e51d58474cb280a64f79f3cc0912" | tr -d '\n' | pbcopy
echo "6d39e51d58474cb280a64f79f3cc0912 -> copied to clipboard"
echo "Add Gist ID to Sync preferences"
echo "VS Code: ACCESS TOKEN REQUIRED"
pause "Press [Enter] to continue…"







section "Configure Dropbox"
open ~/Applications/Dropbox.app
pause "Press [Enter] when completed…"
echo "After Dropbox is configured connect preferences for following apps:"
echo "Alfred"
echo "iTerm2"
echo "Quiver"






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








## Set shell to zsh using `oh-my-zsh`
CUSTOM_ZSH=~/.oh-my-zsh/custom
section "Installing Oh-My-Zsh"
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

## ZSH Powerlevel9k Theme
## https://github.com/bhilburn/powerlevel9k
## https://medium.freecodecamp.org/jazz-up-your-zsh-terminal-in-seven-steps-a-visual-guide-e81a8fd59a38
## https://medium.com/@alex285/get-powerlevel9k-the-most-cool-linux-shell-ever-1c38516b0caa
echo "Cloning 'Powerlevel9k' theme"
git clone https://github.com/bhilburn/powerlevel9k.git $CUSTOM_ZSH/themes/powerlevel9
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
ITERM_SCHEMES="https://github.com/mbadolato/iTerm2-Color-Schemes.git"
echo "Installing iTerm2 Color Schemes from $ITERM_SCHEMES"
git clone $ITERM_SCHEMES ~/.iterm2







echo "Security: https://objective-see.com/products.html"
echo "Additional manual configurations: Java, iCloud"

unset pause
unset section