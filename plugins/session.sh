#!/usr/bin/env bash

current_dir="${BASH_SOURCE[0]%/*}"
[ "$current_dir" = "${BASH_SOURCE[0]}" ] && current_dir="."
source "$current_dir/../lib/utils.sh"

session_icon=$(get_tmux_option "@tmux2k-session-icon" "")
session_format=$(get_tmux_option "@tmux2k-session-format" "#S") # `#W` for window

main() {
    echo "$session_icon $session_format"
}

main
