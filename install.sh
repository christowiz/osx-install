#!/bin/sh

echo Install Homebrew, packages and casks
# Check for Homebrew
if test ! $(which brew)
then
  echo "  Installing Homebrew for you."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" > /tmp/homebrew-install.log
fi

# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade --all

brew tap homebrew/core
brew tap mas-cli/tap
brew tap-pin mas-cli/tap
brew tap caskroom/cask
brew tap caskroom/fonts

brew install bash
brew install ccat
brew install git
brew install git-extras
brew install htop
brew install mas
brew install node
brew install sass
brew install thefuck
brew install tmux
brew install watch
brew install wget

# Core Functionality
echo Install Apps

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
  homebrew/cask-drivers/wacom-table
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

# Nice to have
echo Link Cask Apps to Alfred
brew cask alfred link


echo Install Node packages
mkdir ~/.npm-packages
mkdir /usr/local/n
sudo chown -R $(whoami) /usr/local/n
npm install -g git-open list-scripts n npm-check-updates npm-completion serve trash-cli

echo Update Node/NPM version to latest
n install latest
npm i -g npm@latest

# Fix firewall when using `n` package
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add /usr/local/bin/node


## Get applications from App Store
echo Install App Store applications

APPSTORE=(
  406056744 # Evernote
  942385494 # Memory Purge
  497799835 # Xcode
)

read -p "Sign-in to App Store before continuing.\nPress any key to open App Store." -n1 -s
open /Applications/App\ Store.app
read -p "Press any key to continue after signing into the Apple App Store... " -n1 -s
mas install ${APPSTORE[@]}
echo  '\n'


## Get applications from Git repo
npx repo download christowiz/Spotify-Menubar-App 'Spotify Menubar.app' ~/Applications/Spotify\ Menubar.app


## Sync applications
echo Install VS Code Sync extension
code -install-extension shan.code-settings-sync
echo Add Gist ID to Sync preferences: 6d39e51d58474cb280a64f79f3cc0912
echo VS Code: ACCESS TOKEN REQUIRED



echo Configure Sublime Text
SUBLIME=~/Library/Application\ Support/Sublime\ Text\ 3
mkdir $SUBLIME
echo Install Package Control
echo '{"installed_packages": ["Sync Settings"]}' > $SUBLIME/Packages/User/Package\ Control.sublime-settings
echo '{"access_token": "","auto_upgrade": true,"gist_id": "c10ea5a4adf5ebd0d445787ef306afa6"}' > $SUBLIME/Packages/User/SyncSettings.sublime-settings
wget https://packagecontrol.io/Package%20Control.sublime-package -P $SUBLIME/Installed\ Packages/
echo Sublime Text: ACCESS TOKEN REQUIRED
echo 'Sublime Text: After Dropbox is configured you can link "User" directory.'
echo '> rm -rf $SUBLIME/Packages/User'
echo '> ln -s ~/Dropbox/Sublime\ Text\ 3/ $SUBLIME/Packages/User'

# Messages
echo Log into Dropbox
echo 'After Dropbox is configured connect preferences for following apps:'
echo Alfred
echo iTerm2
echo Quiver

# cleanup
echo Cleanup Homebrew
brew cleanup --force
rm -f -r /Library/Caches/Homebrew/*


echo "Security: https://objective-see.com/products.html"
echo "Additional manual configurations: Java, iCloud"