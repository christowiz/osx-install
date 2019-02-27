#!/bin/sh
echo Install all AppStore Apps at first!
# no solution to automate AppStore installs
read -p "Press any key to continue... " -n1 -s
echo  '\n'

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

brew install bash
brew install ccat
brew install git
brew install git-extras
brew install node
brew install thefuck
brew install wget

brew tap caskroom/cask
brew tap caskroom/fonts

brew cask install java

# Core Functionality
echo Install Apps
brew cask install --appdir="~/Applications" alfred
brew cask install --appdir="~/Applications" bartender
brew cask install --appdir="~/Applications" brave-browser
brew cask install --appdir="~/Applications" caffeine
brew cask install --appdir="~/Applications" cd-to-iterm
brew cask install --appdir="~/Applications" devdocs
brew cask install --appdir="~/Applications" dropbox
brew cask install --appdir="~/Applications" evernote
brew cask install --appdir="~/Applications" expressvpn
brew cask install --appdir="~/Applications" find-any-file
brew cask install --appdir="~/Applications" firefox
brew cask install --appdir="~/Applications" font-fira-code
brew cask install --appdir="~/Applications" franz
brew cask install --appdir="~/Applications" google-chrome
brew cask install --appdir="~/Applications" homebrew/cask-drivers/wacom-table
brew cask install --appdir="~/Applications" homebrew/cask-versions/firefox-developer-edition
brew cask install --appdir="~/Applications" iterm2
brew cask install --appdir="~/Applications" java
brew cask install --appdir="~/Applications" liteswitch-x
brew cask install --appdir="~/Applications" macdown
brew cask install --appdir="~/Applications" sketch
brew cask install --appdir="~/Applications" slack
brew cask install --appdir="~/Applications" sourcetree
brew cask install --appdir="~/Applications" spectacle
brew cask install --appdir="~/Applications" spotify
brew cask install --appdir="~/Applications" sublime-text
brew cask install --appdir="~/Applications" transmit
brew cask install --appdir="~/Applications" visual-studio-code
brew cask install --appdir="~/Applications" zeplin

# Nice to have
echo Link Cask Apps to Alfred
brew cask alfred link


echo Install Node packages
mkdir ~/.npm-packages
mkdir /usr/local/n
sudo chown -R $(whoami) /usr/local/n
npm install -g git-home list-scripts n npm-check-updates npm-completion serve trash-cli


echo Update Node/NPM version to latest
n install latest
npm i -g npm@latest


## Get applications from App Store


## Get applications from Git repo
npx repo download christowiz/Spotify-Menubar-App 'Spotify Menubar.app' ~/Applications/Spotify\ Menubar.app


# cleanup
echo Cleanup Homebrew
brew cleanup --force
rm -f -r /Library/Caches/Homebrew/*


echo "Security: https://objective-see.com/products.html"
echo "Additional manual configurations: Java, iCloud"