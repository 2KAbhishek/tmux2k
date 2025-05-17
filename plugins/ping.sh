#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir/../lib/utils.sh"

ping_function() {
    case $(uname -s) in
    Linux | Darwin)
        pingserver=$(get_tmux_option "@tmux2k-ping-server" "google.com")
        pingtime=$(ping -c 1 "$pingserver" | tail -1 | awk '{print $4}' | awk -F'/' '{printf "%.2f", $2}')
        echo "$pingtime ms"
        ;;

    CYGWIN* | MINGW32* | MSYS* | MINGW*) ;; # TODO - windows compatibility
    esac
}

main() {
    ping_icon=$(get_tmux_option "@tmux2k-ping-icon" "󱘖")
    echo "$ping_icon $(ping_function)"
    RATE=$(get_tmux_option "@tmux2k-refresh-rate" 1)
    sleep "$RATE"
}

main
