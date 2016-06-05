#!/bin/bash


IFS=$'\n'


HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
HOME=$( readlink -f ~ )
MAXDEPTH=3

# I. Get List of Dotfiles


function find_dotfiles {
	echo "$( find $1 -maxdepth $MAXDEPTH ! -name '*.old' ! -path $1'/.config' ! -path $1'/.cache' ! -path $1'/.cache*' ! -path $2 ! -path $2'*' | grep $1'[/]*\.[^.].*' )"
}
function find_oldfiles {
	echo "$( find $HOME -maxdepth $MAXDEPTH ! -name '*.old' ! -path $1'/.config' ! -path $1'/.cache' ! -path $1'/.cache*' ! -path $HERE ! -path $HERE'*' | grep $1'[/]*\.[^.].*' )"
}

_temp="/tmp/answer.$$"

function menu {
	menuitem=$(dialog --backtitle "SYNC.sh - Manage your dotfiles" --title " Main Menu "\
		        --no-cancel \
		        --menu "Move using [UP] [DOWN], [Enter] to select" 17 60 10\
		        Host "Auswählen der lokalen Dotfiles zum Hochladen"\
		        Client "Auswählen der nicht-lokalen Dofiles zum Ersetzen (Automatisches Backup als *.old)"\
		        Backup "Backup-Dateien (*.old) können hier erstellt und gelöscht werden."\
		        Update "Lokale Symlinks aktualisieren"\
		        Info "Lokale Symlinks aktualisieren"\
		        Quit "Script beenden" 2>&1 >/dev/tty)

        case $menuitem in
			Host) echo "Bye";;
			Client) client;;
			Backup) backup;;
			Info) echo "Bye";;
			Update) echo "Bye";;
			Quit) break;;
		esac
}
function client {
	# Clone Git
	dot_git_all="$(find_dotfiles $HERE $HERE'/.git')"

	options=()
	selected=()

	n=1
	for i in ${dot_git_all}
	do
		rel=${i:${#HERE}}
		if [[ $(readlink "$HOME$rel") == "$HERE$rel" ]]
		then
			options+=($n $i "on")
			c=rel
		else
			options+=($n $i "off")
		fi
		n=$((n+1))
	done

	cmd=(dialog --separate-output --ok-label "Update" --checklist "Select options:" 22 76 16)
	choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)


	links=0
	backup=0
	for i in ${choices}
	do
		# Vorheriger, Aktuell selektierter Path
		c=${options[$((1+(i-1)*3))]}

		# Relativer Path
		rel=${c:${#HERE}}

		# Wenn nicht Datei in bereits verlinktem Ordner, bereits verlinkt -> nix; sonst -> LINK + Backup
        test="$(readlink -f $(dirname $HOME$rel))"

        tmp=$(dirname $HOME$rel)
        if [[ "$(readlink -f $tmp)" == "$tmp" ]] && [[ $(readlink -f $HOME$rel) != $(readlink -f $HERE$rel) ]];then
			if [[ -e "$HOME$rel" ]];then
                if [[ -e "$HOME$rel".old ]]; then
                    $(rm -r $HOME$rel'.old')
                fi
				$(mv -bfv "$HOME$rel" "$HOME$rel".old)
				backup=$((backup+1))
			fi
			$(ln -s "$HERE$rel" "$HOME$rel")
			links=$((links+1))
		fi

	done
	dialog --title " Item(s) selected " --msgbox "$links Datei(en) wurde(n) neu verlinkt.\n$backup Datei(en) wurde(n) als Backup gemerkt (*.old)." 6 44
}

function backup {
	test=$(find $HOME -name '*.old' )
	options=$( find . -maxdepth 1  | awk '{print $1}')
	cmd=(dialog --stdout --no-items \
	        --separate-output \
	        --ok-label "Delete" \
	        --checklist "Select options:" 22 306 16)
	choices=$("${cmd[@]}" ${options})

	dialog --title " Item(s) selected " --msgbox "${choices[@]}" 6 44
}
	menu
