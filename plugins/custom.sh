#!/usr/bin/env bash

current_dir="${BASH_SOURCE[0]%/*}"
[ "$current_dir" = "${BASH_SOURCE[0]}" ] && current_dir="."
source "$current_dir/../lib/utils.sh"

custom_icon=$(get_tmux_option "@tmux2k-custom-icon" "")

main() {
    echo "$custom_icon Hello Tmux2K"
}

main
