#!/usr/bin/env bash

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir/../lib/utils.sh"

tdo_icon=$(get_tmux_option "@tmux2k-tdo-icon" "")

main() {
    tdo_count=$(tdo --pending)
    echo "$tdo_icon $tdo_count"
}

main
