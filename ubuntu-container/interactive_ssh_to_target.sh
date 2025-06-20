#!/usr/bin/env bash
set -e

# stolen from:
# https://stackoverflow.com/questions/51616985/how-to-display-a-selection-menu-in-bash-using-options-that-are-stored-in-a-text

FILENAME="./inventory"

if [[ ! -f $FILENAME ]]; then
    >&2 echo "'$FILENAME' does not exist!"
fi

declare -a menu
menu[0]=""

while IFS= read -r line; do
  menu[${#menu[@]}]="$line"
done < $FILENAME

menu() {
  echo "Select target for SSH: "
  echo ""
  for (( i=1; i<${#menu[@]}; i++ )); do
    echo "$i) ${menu[$i]}"
  done
  echo ""
}

menu
read option

while ! [ "$option" -gt 0 ] 2>/dev/null || [ -z "${menu[$option]}" ]; do
  echo "No such option '$option'" >&2
  menu
  read option
done

ip=${menu[$option]}
ssh root@$ip
