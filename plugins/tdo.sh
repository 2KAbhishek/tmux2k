#!/usr/bin/env bash

current_dir="${BASH_SOURCE[0]%/*}"
[ "$current_dir" = "${BASH_SOURCE[0]}" ] && current_dir="."
source "$current_dir/../lib/utils.sh"

tdo_icon=$(get_tmux_option "@tmux2k-tdo-icon" "")

main() {
    local tdo_count
    if tdo_count=$(tdo --pending 2>/dev/null) && [[ "$tdo_count" =~ ^[0-9]+$ ]]; then
        echo "$tdo_icon $tdo_count"
    else
        echo "$tdo_icon "
    fi
}

main
