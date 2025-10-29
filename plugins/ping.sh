#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir/../lib/utils.sh"

ping_function() {
    pingserver=$(get_tmux_option "@tmux2k-ping-server" "google.com")

    if [[ "$pingserver" == *:* ]]; then
        host=${pingserver%%:*}
        port=${pingserver##*:}
        
        start_time=$(date +%s.%N)
        if nc -z -w 1 "$host" "$port" 2>/dev/null; then
            end_time=$(date +%s.%N)
            duration=$(echo "$end_time - $start_time" | bc)
            printf "%.2fs\n" "$duration"
        else
            echo "-.--s"
        fi
    else
        os_type=$(uname)
        case "$os_type" in
            Linux*)
                # Linux: rtt min/avg/max/mdev = 12.345/67.890/123.456/7.890 ms
                pingtime=$(ping -c 1 "$pingserver" | tail -1 | awk -F'/' '/^rtt/ {print $5}')
                ;;
            Darwin*)
                # macOS: round-trip min/avg/max/stddev = 12.345/67.890/123.456/7.890 ms
                pingtime=$(ping -c 1 "$pingserver" | tail -1 | awk -F'/' '/^round-trip/ {print $2}')
                ;;
            *)
                # Fallback: try Linux format
                pingtime=$(ping -c 1 "$pingserver" | tail -1 | awk -F'/' '{print $5}')
                ;;
        esac
        if [[ -n "$pingtime" ]]; then
            # convert ms to seconds
            duration=$(echo "$pingtime / 1000" | bc -l)
            printf "%.2fs\n" "$duration"
        else
            echo "-.--s"
        fi
    fi
}

main() {
    ping_icon=$(get_tmux_option "@tmux2k-ping-icon" "󱘖")
    echo "$ping_icon $(ping_function)"
    RATE=$(get_tmux_option "@tmux2k-refresh-rate" 1)
    sleep "$RATE"
}

main
