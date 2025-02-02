#!/bin/bash

export CONTINUE="Press [Enter] to continue…"

function pause() {
  read -pr "$* $CONTINUE"
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
  read -pr "$* (y/n): "
  if [ "$REPLY" = "y" ]; then
    return 0
  else
    return 1
  fi
}

function noCheck() {
  read -pr "$* (y/n): "
  if [ "$REPLY" = "n" ]; then
    return 0
  else
    return 1
  fi
}

function utilsUnset() {
  unset CONTINUE
  unset pause
  unset action
  unset section
  unset yesCheck
  unset noCheck
  unset utilsUnset
}
