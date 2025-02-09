#!/usr/bin/env bash

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir/../lib/utils.sh"

session_icon=$(get_tmux_option "@tmux2k-session-icon" "session")

main() {
    case $session_icon in
    session) session_icon=" #S" ;;
    window) session_icon=" #W" ;;
    esac

    echo "$session_icon"
}

main
