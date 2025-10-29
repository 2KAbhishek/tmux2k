#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir/../lib/utils.sh"

normalize_time() {
    value="$1"
    unit="$2"
    # Convert to ms if needed
    case "$unit" in
        ms) printf "%.2f ms" "$value" ;;
        s) printf "%.2f ms" "$(echo "$value * 1000" | bc -l)" ;;
        *) printf "%s" "$value" ;;
    esac
}

ping_function() {
    pingserver=$(get_tmux_option "@tmux2k-ping-server" "google.com")
    host="${pingserver%%:*}"
    port="${pingserver##*:}"
    if [[ "$pingserver" == *:* && "$port" != "$host" ]]; then
        start=$(date +%s%3N)
        if exec 3<>/dev/tcp/"$host"/"$port"; then
            end=$(date +%s%3N)
            exec 3>&-
            duration=$((end - start))
            normalize_time "$duration" ms
        else
            echo "N/A"
        fi
    else
        case $(uname -s) in
            Linux | Darwin)
                ping_output=$(ping -c 1 "$pingserver")
                avg_time=$(echo "$ping_output" | awk -F'=' '/min\/avg\/max/ {split($2, a, "/"); print a[2]}' | tr -d ' ')
                # Detect float and unit
                if [[ "$avg_time" == *.* ]]; then
                    # Assume ms if less than 50, s if >= 1
                    val="$avg_time"
                    unit="ms"
                    # Some pings can output >1, consider <10 as s, >10 as ms
                    if (( $(echo "$val >= 1" | bc) )) && (( $(echo "$val < 50" | bc) )); then
                        unit="ms"
                    elif (( $(echo "$val >= 50" | bc) )); then
                        unit="ms"
                    elif (( $(echo "$val < 1" | bc) )); then
                        unit="s"
                    fi
                    normalize_time "$val" "$unit"
                else
                    normalize_time "$avg_time" ms
                fi
                ;;
            CYGWIN* | MINGW32* | MSYS* | MINGW*)
                # Windows compatibility stub
                ;;
        esac
    fi
}

main() {
    ping_icon=$(get_tmux_option "@tmux2k-ping-icon" "󱘖")
    echo "$ping_icon $(ping_function)"
    RATE=$(get_tmux_option "@tmux2k-refresh-rate" 1)
    sleep "$RATE"
}

main
