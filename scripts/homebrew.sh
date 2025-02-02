#!/bin/bash

export BREW_APP_DIR=$HOME/Applications
export BREW_FORMULAES=(
  asciinema
  atuin
  autojump
  automake
  aws-amplify
  aws-rotate-key
  awscli
  bash
  bash-completion
  bat
  berkeley-db
  bfg
  brew-cask-completion
  brew-gem
  bun
  caddy
  ccat
  cmake
  coreutils
  curl
  deno
  diff-so-fancy
  dust
  fastfetch
  firefly
  fx
  fzf
  gh
  git
  git-extras
  git-filter-repo
  gitui
  gnu-sed
  gnupg
  go
  grep
  hashicorp/tap/vault
  helix
  htop
  hub
  hyperfine
  ios-deploy
  java
  jless
  jpeg
  jq
  kubernetes-cli
  lastpass-cli
  lazygit
  mcfly
  midnight-commander
  mkcert
  mongodb-atlas-cli
  mongodb-community
  mongodb-database-tools
  mongosh
  multitime
  nativefier
  neofetch
  neovide
  neovim
  nnn
  node
  openssh
  perl
  pipx
  pkgx
  powerlevel10k
  python
  qemu
  ranger
  ruby
  soundsource
  spoof-mac
  sqlite
  superfile
  telnet
  terminal-notifier
  thefuck
  tldr
  tor
  tree
  unbound
  util-linux
  vault
  virtualenv
  watchman
  wget
  xz
  yazi
  yq
  zellij
  zip
  zork
  zsh
  zsh-autocomplete
  zsh-history-substring-search
)

# Core Functionality
export BREW_CASK_APPS=(
  a-better-finder-rename
  adoptopenjdk
  adoptopenjdk8
  alfred
  android-studio
  app-tamer
  apparency
  appcleaner
  authy
  bartender
  box-drive
  brave-browser
  caffeine
  cakebrewjs
  calibre
  ccleaner
  cyberduck
  daedalus-mainnet
  discord
  disk-inventory-x
  diskcatalogmaker
  docker
  dropbox
  dteoh-devdocs
  eloston-chromium
  expressvpn
  fig
  figma
  find-any-file
  firefly
  firefly-shimmer
  firefox
  firefox-developer-edition
  fluid
  font-fira-code
  font-hack-nerd-font
  gimp
  ghostty
  gitbutler
  github
  google-chrome
  google-chrome-canary
  grandperspective
  handbrake
  http-toolkit
  iina
  imageoptim
  inkscape
  iterm2
  jordanbaird-ice
  keyboard-cleaner
  kindle
  kindle-previewer
  kitty
  krita
  lastpass
  launchcontrol
  ledger-live
  lingon-x
  livebook
  macdown
  macsvg
  memory-cleaner
  microsoft-edge
  mongodb-compass
  multipass
  mutespotifyads
  neohtop
  obsidian
  omnidisksweeper
  openvpn-connect
  oracle-jdk
  oversight
  pinta
  postman
  qlcolorcode
  qlimagesize
  qlmarkdown
  qlstephen
  qlvideo
  qobuz
  quicklook-json
  quicklookase
  rectangle
  rive
  scroll-reverser
  sigmaos
  skype
  slack
  sloth
  sonos
  sourcetree
  spotify
  statusfy
  studio-3t
  suspicious-package
  syncthing
  syntax-highlight
  tor-browser
  transmission
  tunnelblick
  utm
  visual-studio-code
  vlc
  vscodium
  vnc-viewer
  wave
  whatsapp
  webstorm
  wine-stable
  xbar
  xquartz
  xscope
  zed
  zulu11
)

export BREW_CASK_NO_QUARANTINE=(
  syntax-highlight
)

function install_homebrew() {
  if test ! "$(which brew)"; then
    echo "Installing homebrew..."
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi

  echo -e "\nMake sure we're using the latest Homebrew"
  action "Updating Brew…"
  brew update

  echo -e "\nUpgrade any already-installed formulae"
  action "Upgrading Brew…"
  brew upgrade

  action "Installing Brewfile"
  brew bundle

  # action "Installing Brew CLI Formulae"
  # brew install "${BREW_FORMULAES[@]}"

  # Symlink Java
  action "Configuring Java install"
  sudo ln -sfn /opt/homebrew/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk

  # action "Installing Brew Cask Apps"
  # brew install --appdir="$BREW_APP_DIR" "${BREW_CASK_APPS[@]}"
  # brew install --cask --appdir="$BREW_APP_DIR" --no-quarantine "${BREW_CASK_NO_QUARANTINE[@]}"

  # cleanup
  echo "Cleanup Homebrew"
  brew cleanup --verbose -s
  rm -rf "$(brew --cache)"

  unset BREW_APP_DIR
  unset BREW_CASK_APPS
  unset BREW_FORMULAES
  unset BREW_CASK_NO_QUARANTINE
}
