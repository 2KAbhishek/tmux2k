#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir"/utils.sh

ping_function() {
    case $(uname -s) in
    Linux | Darwin)
        pingserver=$(get_tmux_option "@tmux2k-ping-server" "google.com")
        pingtime=$(ping -c 1 "$pingserver" | tail -1 | awk '{print $4}' | cut -d '/' -f 2)
        echo "$pingtime ms"
        ;;

    CYGWIN* | MINGW32* | MSYS* | MINGW*) ;; # TODO - windows compatability
    esac
}

main() {

    echo "$(ping_function)"
    RATE=$(get_tmux_option "@tmux2k-ping-rate" 5)
    sleep "$RATE"
}

main
