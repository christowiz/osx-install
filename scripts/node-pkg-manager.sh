#!/bin/bash

source ./utils.sh

export NPM_APPS=(
  # alfred-updater
  # alfred-bundlephobia
  # alfred-updater
  bundle-phobia-cli
  chii
  corepack
  degit
  depcheck
  es-check
  fkill-cli
  git-alias
  git-open
  goops
  http-server
  list-scripts
  live-server
  local-ssl-proxy
  memlab
  node-inspector
  npkill
  npm
  npm-check
  npm-check-unused
  npm-check-updates
  npm-completion
  npm-ls-scripts
  nx
  serve
  sirv-cli
  trash-cli
)

function install_pnpm() {
  action "Installing PNPM"
  if yesCheck "Would you like to install PNPM? "; then
    # brew install yarn
    # corepack enable yarn
    # curl -fsSL https://get.pnpm.io/install.sh | env PNPM_VERSION=10.0.0 sh -
    wget -qO- https://get.pnpm.io/install.sh | ENV="$HOME/.zshrc" SHELL="$(which zsh)" bash -
  fi

  action "Installing global NPM packages w/PNPM"
  pnpm add -g "${NPM_APPS[@]}"

  unset NPM_APPS
}
