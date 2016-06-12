#!/bin/bash

# Copyright (c) 2016 Sebastian Kussl
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# -------------------------------------
#  GLOBAL PARAMETER
# -------------------------------------

HERE=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
HOME=$( readlink -f ~ )
#EXECPTIONS=()
MAXDEPTH=3

REGDOT=/+\.[^. ][^ ]*



# -------------------------------------
#  METHODS
# -------------------------------------

function menu {
	local menuitem=$(dialog --backtitle "SYNC.sh - Manage your dotfiles" \
                            --title " Main Menu "\
        		            --no-cancel \
        		            --menu "Move using [UP] [DOWN] [TAB], [Enter] to select" 17 60 10 \
                		        "Download" "Dotfiles auf diesem System verlinken" \
                		        "Upload" "Lokale Dateien hinzufügen" \
                		        "GIT PULL" "´git pull´ ausführen" \
                		        "GIT PUSH" "´git push´ ausführen" \
                                "Backup" "Wiederherstellen/Löschen" \
                		        "Info" "Parameteranzeige" \
                		        "Quit" "Beenden" \
                		        3>&1 1>&2 2>&3 3>&-)

    case $menuitem in
		"Download")   download;;
		"Upload")     upload;;
		"GIT PULL")   git_pull;;
		"GIT PUSH")   git_push;;
        "Backup")     backup;;
		"Info")       info;;
		"Quit")       clear && break;;
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
function download {
    IFS=$'\n' 
    # DATEIEN FINDEN
	local files=$(find $HERE -maxdepth $MAXDEPTH ! -type l \
                                                 ! -path $HERE \
                                                 ! -path $HERE'/.git*' \
                                                 ! -path '*.old*' \
                                                 ! -name '*.swp' \
                                                 | grep -E '^'$HERE'/+\.[^.]\S*$')

	# BEREITS VORHANDENE VERLINKUNG CHECKEN
	local options=()
    for i in ${files}; do

	    target=$HOME${i:${#HERE}}

        if [[ $(readlink $target) == $(readlink -f $i) ]]; then
		    options+=($i "on")
	    else
		    options+=($i "off")
	    fi

    done
    unset IFS
    local choices=$(dialog --no-items \
                           --checklist "Select options:" 22 200 16 ${options[@]} 3>&1 1>&2 2>&3 3>&-)
    local new=0
    local bak=0
    local err=0


    for i in ${choices}; do
	   
        local target=$HOME${i:${#HERE}}

        if [[ $target == $HOME ]] || ( [[ -e $target ]] && [[ $(readlink -f $(dirname $target)) != $(dirname $target) ]] ); then
            err=$((err+1))
        elif [[ -h $target ]]; then
            $(rm $target)
            $(mkdir -p $(dirname $target))
            $(ln -s $i $target)
            new=$((new+1))
        elif [[ -e $target ]] && [[ -e $target.old ]]; then
            err=$((err+1))
            dialog --title "Information" --msgbox "Error: Sowohl '$(basename $target)' als auch '$(basename $target.old)' existieren bereits am Zielort! In der Backup-Verwaltung können alte Dateien gelöscht werden." 8 44
        elif [[ -e $target ]]; then
            if dialog --stdout --title "SYNC.sh" \
                          --backtitle "Aktion erforderlich" \
                          --no-label "Cancel" \
                          --yesno "'$target' (existiert bereits) nach '$target.old' verschieben?" 7 60; then
                $(mv $target $target.old)
                $(ln -s $i $target)
                new=$((new+1))
                bak=$((bak+1))
            else
                err=$((err+1))
            fi
        else
            $(ln -s $i $target)
            new=$((new+1))
        fi

    done

	dialog --title "Fertig" --msgbox "$new verlinkt.\n$bak gebackuped.\n$err abgebrochen." 8 44
}
function upload {

	local options=$( find $HOME -maxdepth $MAXDEPTH ! -type l \
                                                  ! -path '*.old*' \
                                                  ! -name '*.swp' \
                                                  ! -path $HOME'/.config' \
                                                  ! -path $HOME'/.cache' \
                                                  ! -path $HOME'/.ssh*' \
                                                  ! -path $HOME'/.cache*' \
                                                  ! -path $HERE \
                                                  ! -path $HERE'*' \
                                                  | grep -E $HOME'/+\.[^. ][^ ]*' \
                                                  | awk '{print $1, "off"}')

	local choices=$(dialog --no-items \
				     --checklist "Select options:" 22 200 16 ${options[@]} 3>&1 1>&2 2>&3 3>&-)

    local new=0
    local bak=0
    local err=0

	for i in ${choices}; do
		local target=$HERE${i:${#HOME}}

        if [[ $target == $HERE ]]; then
           break; 
        elif [[ -e $target ]] && [[ -e $target.old ]]; then
            err=$((err+1))
            dialog --title "Information" --msgbox "Error: Sowohl '$(basename $target)' als auch '$(basename $target.old)' existieren bereits am Zielort! In der Backup-Verwaltung können alte Dateien gelöscht werden." 8 44
        elif [[ -e $target ]]; then
            if dialog --stdout --title "SYNC.sh" \
                          --backtitle "Aktion erforderlich" \
                          --no-label "Cancel" \
                          --yesno "'$target' (existiert bereits) nach '$target.old' verschieben?" 7 60; then
                $(mv $target $target.old)
                $(cp $i $target)
                new=$((new+1))
                bak=$((bak+1))
            else
                err=$((err+1))
            fi
        else
            $(cp $i $target)          
            new=$((new+1))
        fi

	done
	dialog --title "Information" --msgbox "$new verlinkt.\n$bak gebackuped.\n$err abgebrochen." 8 44
}
function backup {
	local options=$(find $HOME -maxdepth $MAXDEPTH \
                               -name '*.old' \ 
                             ! -path $HOME'/.cache*' \
                             ! -path $HERE'*' \
                             | grep -E $HOME$REGDOT \
                             | awk '{print $1, "off"}')
	
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
   
        if [[ $action -eq 0 ]]; then 
            local target=${i::-4}
            if [[ -h $target ]]; then
                $(rm $target)
                $(mv $i $target)
            elif [[ -e $target ]]; then
                err=$((err+1))
            else
                $(mv $i $target)
                res=$((res+1))
            fi
        elif [[ $action -eq 3  ]]; then
            $(rm $i)
            del=$((del+1))
        fi
   
    done    
}
function info {
    dialog --title "Information" --msgbox "home (~): $HOME\ndotfiles: $HERE\nmaxdepth: $MAXDEPTH" 8 44
}

while true; do
	menu
done
