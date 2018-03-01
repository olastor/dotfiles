#!/bin/bash

function add_dotfile {
  if ! [ -e $1 ]; then
    echo "The file $1 does not exist!"
    exit
  fi

  # Add exception to .gitignore
  echo "!$1" >> .gitignore

  # Commit change
  git add $1 .gitignore
  git commit -m "Added $1"
}

function rm_dotfile {
  # Delete exception(s) from .gitignore
  grep -nF $1 .gitignore | cut -f1 -d: | tac | xargs -I{} sed -i "{}d" .gitignore

  # Commit change
  git add $1 .gitignore
  git commit -m "Removed $1"
}

while getopts a:d: opt
do
  case $opt in
    a) add_dotfile $OPTARG;;
    d) rm_dotfile $OPTARG;;
  esac
done
