#!/bin/bash


#IFS=$'\n'


HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
HOME=$( readlink -f ~ )
MAXDEPTH=2

# I. Get List of Dotfiles


function find_dotfiles {
	echo "$( find $1 -maxdepth $MAXDEPTH ! -name '*.old' ! -path $1'/.config' ! -path $1'/.cache' ! -path $1'/.cache*' ! -path $2 ! -path $2'*' | grep $1'[/]*\.[^.].*' )"
}

_temp="/tmp/answer.$$"

function menu {
	menuitem=$(\ 
				dialog --backtitle "SYNC.sh - Manage your dotfiles" --title " Main Menu "\
		        --no-cancel \
		        --menu "Move using [UP] [DOWN], [Enter] to select" 17 60 10\
		        "Link" "Dotfiles auf diesem System verlinken"\
		        "Add" "Lokale Dateien hinzufügen"\
		        "GIT PULL" "git pull ausführen"\
		        "GIT PUSH" "git push ausführen (Achtung!)"\
		        "Backup" "Backup-Dateien verwalten"\
		        "Quit" "Script beenden" \
		        3>&1 1>&2 2>&3 3>&- \
		      )

    case $menuitem in
		"Link") client;;
		"Add") host;;
		"GIT PULL") dialog --title "Information" --msgbox "$(git pull)" 6 44;;
		"GIT PUSH") git_push;;
		"Backup") backup;;
		"Quit") clear && break;;
	esac

	
}
function git_pull {
	dialog --title "Information" --msgbox "$(git pull)" 6 44
	
}
function git_push {
	git add -A 
	git commit -m 'SYNC.sh update'
	git push
	dialog --title "Information" --msgbox "Done" 6 44
}
function client {
	# Dateien aus $HERE finden
	gitfiles=$(find $HERE -maxdepth $MAXDEPTH ! -path '*.git' ! -path $HERE'/.git*' | grep $HERE'[/]*\.[^.].*')

	# Überprüfen, ob bereits verlinkt
	options=()
	for i in ${gitfiles}; do
		target=$HOME${i:${#HERE}}

		if [[ $(readlink $target) == $i ]]; then
			options+=($i "on")
		else
			options+=($i "off")
		fi
	done

	# Falls keine Dateien gefunden wurden
	if [[ ${gitfiles[0]} != "" ]]; then
		# Auswählen lassen
		cmd=(dialog --stdout --no-items \
		        --separate-output \
		        --ok-label "Choose" \
		        --checklist "Select options:" 22 200 16 )
		choices=$("${cmd[@]}" $(echo ${options[@]}))

		# Ausgewählte neu verlinken
		n=0
		for i in ${choices}; do
			target=$HOME${i:${#HERE}}

			tmp=$(dirname $i)
			parent=$HOME${tmp:${#HERE}}

			if [[ $(readlink $parent) == "" ]] ; then

				# Erstelle Verzeichnis, falls nicht da
				$(mkdir -p $parent)

				# Wenn Lokale Datei kein Symlink
				if [[ ! -L $target ]];then
					# Lösche alte .old
		            $(rm -rf $target'.old')

		            # Verschiebe lokale nach .old
		            $(mv -bfv $target $target.old)
					
					n=$((n+1))
				fi

				# Lösche Symlinks
		        $(rm -rf $target)

	            # Verlinke neu
				$(ln -s $i $target)

			fi
		done
		echo ${options}

		dialog --title "Information" --msgbox "$n Dateien wurden neu verlinkt." 6 44
	fi
}
function host {
	# Dateien aus $HERE finden
	options=$( find $HOME -maxdepth $MAXDEPTH ! -name '*.old' ! -path $HOME'/.config' ! -path $HOME'/.cache' ! -path $HOME'/.cache*' ! -path $HERE ! -path $HERE'*' | grep $HOME'[/]*\.[^.].*' | awk '{print $1, "off"}')

	# Falls keine Dateien gefunden wurden
	if [[ ${options[0]} != "" ]]; then
		
		# Auswählen lassen
		choices=$(dialog --no-items \
				         --ok-label "Choose" \
				         --checklist "Select options:" 22 200 16 $options 3>&1 1>&2 2>&3 3>&-)

		for i in ${choices}; do
			dialog --title "Information" --msgbox "$i" 6 44
		done

	fi

}
function backup {
	options=$(find $HOME -maxdepth $MAXDEPTH -name '*.old' ! -path $HOME'/.config' ! -path $HOME'/.cache' ! -path $HOME'/.cache*' ! -path $HERE ! -path $HERE'*' | grep $1'[/]*\.[^.].*' | awk '{print $1, "on"}')
	
	# Falls keine Dateien gefunden wurden
	if [[ ${options[0]} != "" ]]; then

		# Dateien auswählen
		cmd=(dialog --stdout --no-items \
		        --separate-output \
		        --ok-label "Auswählen" \
		        --checklist "Select options:" 22 200 16 )
		choices=$("${cmd[@]}" $(echo ${options[@]}))
		
		# Option 1: Wiederherstellen
		dialog --stdout --title "What to do?" \
			  --backtitle "Backup-Verwaltung" \
			  --yesno "Wollen Sie die ausgewählten Dateien wiederherstellen?" 7 60
		
		operation=$?

		# Option 2: Löschen (Wenn nicht wiederherstellen)
		if [[ $operation -eq 1 ]]; then
			dialog --stdout --title "What to do?" \
			  --backtitle "Backup-Verwaltung" \
			  --yesno "Wollen Sie die ausgewählten Dateien löschen?" 7 60
			operation=$?
			if [[ $operation -eq 0 ]]; then
				operation=1
			else
				operation=2
			fi
		fi
		
		# Ausführen
		n=0
		for i in ${choices}; do
			if [[ $operation -eq 0 ]]; then
				$(mv -bfv $i ${i::-4})
			elif [[ $operation -eq 1 ]]; then
				$(rm -r $i)
			fi
			n=$((n+1))
		done

		# Report
		if [[ $operation -eq 0 ]]; then
			dialog --title "Information" --msgbox "$n Dateien wurden wiederhergestellt." 6 44
		elif [[ $operation -eq 1 ]]; then
			dialog --title "Information" --msgbox "$n Dateien wurden gelöscht." 6 44
		fi
	fi
	
}

while true; do
	menu
done
