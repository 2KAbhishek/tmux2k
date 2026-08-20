#!/usr/bin/env bash

current_dir="${BASH_SOURCE[0]%/*}"
[ "$current_dir" = "${BASH_SOURCE[0]}" ] && current_dir="."
source "$current_dir/../lib/utils.sh"

tdo_icon=$(get_tmux_option "@tmux2k-tdo-icon" "")

main() {
    if ! command -v tdo &>/dev/null; then
        return
    fi
    tdo_count=$(tdo --pending)
    echo "$tdo_icon $tdo_count"
}

main
