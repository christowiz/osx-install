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
if yesCheck "Would you like to install Prey?"; then
  Open https://preyproject.com
  pause
fi
