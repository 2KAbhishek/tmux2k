#!/usr/bin/env bash

current_dir="${BASH_SOURCE[0]%/*}"
[ "$current_dir" = "${BASH_SOURCE[0]}" ] && current_dir="."
source "$current_dir/../lib/utils.sh"

uptime_icon=$(get_tmux_option "@tmux2k-uptime-icon" "󱎫")

get_uptime() {
    local secs=""

    if [ -r /proc/uptime ]; then
        local sec_float
        read -r sec_float _ < /proc/uptime
        secs="${sec_float%%.*}"
    elif command -v sysctl >/dev/null 2>&1; then
        local boottime
        boottime=$(sysctl -n kern.boottime 2>/dev/null)
        if [[ "$boottime" =~ (^|[^a-zA-Z])sec[[:space:]]*=[[:space:]]*([0-9]+) ]]; then
            local now
            now=$(date +%s)
            secs=$(( now - BASH_REMATCH[2] ))
        elif [[ "$boottime" =~ ^[0-9]+$ ]]; then
            local now
            now=$(date +%s)
            secs=$(( now - boottime ))
        fi
    fi

    if [ -z "$secs" ]; then
        return
    fi

    [ "$secs" -lt 0 ] && secs=0

    local d=$((secs / 86400))
    local h=$(( (secs % 86400) / 3600 ))
    local m=$(( (secs % 3600) / 60 ))

    local uptime_str=""
    [ "$d" -gt 0 ] && uptime_str="${uptime_str}${d}D "
    [ "$h" -gt 0 ] && uptime_str="${uptime_str}${h}H "
    uptime_str="${uptime_str}${m}M"

    echo "$uptime_str"
}

main() {
    local uptime_str
    uptime_str=$(get_uptime)

    [ -z "$uptime_str" ] && return

    printf "%s %s\n" "$uptime_icon" "$uptime_str"
}

main
