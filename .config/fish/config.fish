function cc
    clear
end
function ll
    ls --human-readable -l $argv
end
function qer
    xbps-query $argv
end
function inst
    sudo xbps-install -S $argv
end
function rem
    sudo xbps-remove $argv
end
function upd
    sudo xbps-install -Syu $argv
end
function reb
    sudo reboot
end
function pof
    sudo poweroff
end
