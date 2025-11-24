#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir/../lib/utils.sh"

ping_function() {
    case $(uname -s) in
    Linux | Darwin)
        pingserver=$(get_tmux_option "@tmux2k-ping-server" "google.com")

        if [[ "$pingserver" == *:* ]]; then
            host="${pingserver%:*}"
            port="${pingserver##*:}"
            timeout_val=$(get_tmux_option "@tmux2k-ping-timeout" "3")

            start_time=$(date +%s%3N)
            if timeout "${timeout_val}" nc -z "$host" "$port" 2>/dev/null; then
                end_time=$(date +%s%3N)
                duration=$((end_time - start_time))
                echo "${duration} ms"
            else
                echo ""
            fi
        else
            pingtime=$(ping -c 1 "$pingserver" | tail -1 | awk '{split($4, times, "/"); printf "%.2f", times[2]}')
            echo "$pingtime ms"
        fi
        ;;

    CYGWIN* | MINGW32* | MSYS* | MINGW*) ;; # TODO - windows compatibility
    esac
}

main() {
    ping_icon=$(get_tmux_option "@tmux2k-ping-icon" "󱘖")
    echo "$ping_icon $(ping_function)"
}

main
