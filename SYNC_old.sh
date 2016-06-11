#!/bin/bash




HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
HOME=$( readlink -f ~ )
MAXDEPTH=2


s=" |   "
if [[ $HOME =~ $s ]] || [[  $HERE =~ $s ]]; then
    echo "Menschen mit Whitespace in ihren Datei-/Ordnernamen verdienen dieses Script nicht!"
    exit
fi


function menu {
	menuitem=$(\ 
				dialog --backtitle "SYNC.sh - Manage your dotfiles" --title " Main Menu "\
		        --no-cancel \
		        --menu "Move using [UP] [DOWN], [Enter] to select" 17 60 10\
		        "Download" "Dotfiles auf diesem System verlinken"\
		        "Upload" "Lokale Dateien hinzufügen"\
		        "GIT PULL" "´git pull´ ausführen"\
		        "GIT PUSH" "´git push´ ausführen"\
                "Backup" "Wiederherstellen/Löschen"\
		        "Info" "Parameteranzeige"\
		        "Quit" "Beenden" \
		        3>&1 1>&2 2>&3 3>&- \
		      )

    case $menuitem in
		"Download") client;;
		"Upload") host;;
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
	clear
	git add -A 
	git commit -m 'SYNC.sh update'
	git status
	git push
	dialog --title "Information" --msgbox "git push: Fertig!" 6 44
}
function client {
    
    IFS=$'\n'
    
    # Dateien aus $HERE finden
	local gitfiles=$(find $HERE -maxdepth $MAXDEPTH ! -path '*.git' ! -path $HERE'/.git*' ! -name '*.old' | grep $HERE'[/]*\.[^.].*')

	# Überprüfen, ob bereits verlinkt
	local options=()
    for i in ${gitfiles}; do

        if [[ $i =~ ^[^\ ]*$ ]]; then

		    target=$HOME${i:${#HERE}}

		    if [[ $(readlink $target) == $i ]]; then
			    options+=($i "on")
		    else
			    options+=($i "off")
		    fi

        fi

    done

    unset IFS

    local choices=$(dialog --no-items \
                     --checklist "Select options:" 22 200 16 ${options[@]} 3>&1 1>&2 2>&3 3>&-)
    local nw=0
    local bk=0
    local er=0
    for i in ${choices}; do
		local target=$HOME${i:${#HERE}}
        
        if [[ -e $target ]]; then
            if [[ -h $target ]]; then
                $(rm $target)
                $(ln -s $i $target)
            else
                if dialog --stdout --title "SYNC.sh" \
                          --backtitle "Aktion erforderlich" \
                          --no-label "Cancel" \
                          --yesno "'$target' (existiert bereits) nach '$target.old' verschieben?" 7 60; then
                    if [[ -e $target'.old' ]]; then
                        er=$((er+1))
	                    dialog --title "Information" --msgbox "Error: '$target.old' existiert auch bereits!" 8 44
                    else
                        $(mv $target $target.old)
                        $(ln -s $i $target)
                        nw=$((nw+1))
                        bk=$((bk+1))
                    fi
                else
                    er=$((er+1))
                fi
            fi
        fi
    done

	dialog --title "Information" --msgbox "$nw verlinkt.\n$bk gebackuped.\n$er abgebrochen." 8 44
}
function host {
	# Dateien aus $HERE finden
	local options=$( find $HOME -maxdepth $MAXDEPTH -type f ! -name '*.old' ! -path $HOME'/.config' ! -path $HOME'/.cache' ! -path $HOME'/.ssh*' ! -path $HOME'/.cache*' ! -path $HERE ! -path $HERE'*' | grep $HOME'[/]*\.[^.].*' | awk '{print $1, "off"}')

	# Auswählen lassen
	local choices=$(dialog --no-items \
				     --checklist "Select options:" 22 200 16 ${options[@]} 3>&1 1>&2 2>&3 3>&-)

    local nw=0
    local bk=0
    local er=0
	for i in ${choices}; do
		local target=$HERE${i:${#HOME}}
        if [[ -e $target ]]; then
                if dialog --stdout --title "SYNC.sh" \
                          --backtitle "Aktion erforderlich" \
                          --no-label "Cancel" \
                          --yesno "'$target' (existiert bereits) nach '$target.old' verschieben?" 7 60; then
                    if [[ -e $target'.old' ]]; then
                        er=$((er+1))
	                    dialog --title "Information" --msgbox "Error: '$target.old' existiert auch bereits!" 8 44
                    else
                        $(mv $target $target.old)
                        $(ln -s $i $target)
                        nw=$((nw+1))
                        bk=$((bk+1))
                    fi
                else
                    er=$((er+1))
                fi
            fi
	done
	dialog --title "Information" --msgbox "$nw verlinkt.\n$bk gebackuped.\n$er abgebrochen." 8 44
}
function backup {
	local options=$(find $HOME -maxdepth $MAXDEPTH -name '*.old' ! -path $HOME'/.config' ! -path $HOME'/.cache' ! -path $HOME'/.cache*' ! -path $HERE ! -path $HERE'*' | grep $1'[/]*\.[^.].*' | awk '{print $1, "off"}')
	
	local choices=$(dialog --no-items \
				     --checklist "Select options:" 22 200 16 ${options[@]} 3>&1 1>&2 2>&3 3>&-)
		
    $(dialog --stdout --title "What to do?" \
			        --backtitle "Backup-Verwaltung" \
                    --yes-label "Wiederherstellen" \ 
                    --extra-button --extra-label "Löschen" \
                    --yesno "Wollen Sie die ausgewählten Dateien wiederherstellen?" 7 60)
    local action=$?
    local del=0
    local res=0
    local err=0 
    for i in ${choices}; do
   
        if [[ "$action" -eq 0 ]]; then 
            local target=${i::-4}
            if [[ -h $target ]]; then
                $(rm $target)
                $(mv $i $target)
            elif [[ -e $target ]]; then
                err=$((err+1))
            else
                $(mv $i $target)
            fi
        elif [[ "$action" -eq 3  ]]; then
            $(rm $i)
        fi
   
    done    
}
while true; do
	menu
done
