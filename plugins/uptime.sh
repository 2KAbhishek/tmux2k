#!/usr/bin/env bash

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir/../lib/utils.sh"

uptime_icon=$(get_tmux_option "@tmux2k-uptime-icon" "󰀠")

main() {
    uptime_output=$(uptime)
    uptime_text=$(echo "$uptime_output" | awk -F'up ' '{print $2}' | awk -F',' '{print $1}')

    days=0
    hours=0
    minutes=0

    echo "$uptime_text" | awk '
{
    for (i = 1; i <= NF; i++) {
        if ($i ~ /^[0-9]+$/ && $(i+1) == "days") { days = $i }
        if ($i ~ /^[0-9]+:[0-9]+$/) { split($i, t, ":"); hours = t[1]; minutes = t[2] }
        if ($i ~ /^[0-9]+$/ && $(i+1) == "hours") { hours = $i }
        if ($i ~ /^[0-9]+$/ && $(i+1) == "mins") { minutes = $i }
    }
}
END { printf "%d %d %d\n", days, hours, minutes }' | {
        read  days hours minutes

        output=""
        [ "$days" -gt 0 ] && output="$output${days}D "
        [ "$hours" -gt 0 ] && output="$output${hours}H "
        [ "$minutes" -gt 0 ] && output="$output${minutes}M"

        echo "$uptime_icon $output"
    }
}

main
