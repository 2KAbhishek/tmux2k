#!/usr/bin/env bash

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir/../lib/utils.sh"

uptime_icon=$(get_tmux_option "@tmux2k-uptime-icon" "󰀠")

main() {
    uptime | awk '
    {
        for(i=1;i<=NF;i++) {
            if($i=="up") {
                if($(i+1) ~ /^[0-9]+$/ && $(i+2) ~ /^day/) d=$(i+1)
                else if($(i+1) ~ /^[0-9]+:[0-9]+/) {split($(i+1),t,":"); h=t[1]; m=t[2]}
            }
            if($i ~ /^[0-9]+:[0-9]+/) {split($i,t,":"); h=t[1]; m=t[2]}
        }
        gsub(/,/,"",m)
        printf "%s %s%s%s\n", "'"$uptime_icon"'", \
            (d?d"D ":""), \
            (h?h"H ":""), \
            (m?m"M":"")
    }'
}

main
