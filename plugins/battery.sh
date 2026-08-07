#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir/../lib/utils.sh"

charging_icon=$(get_tmux_option "@tmux2k-battery-charging-icon" "")
battery_missing=$(get_tmux_option "@tmux2k-battery-missing-icon" "󱉝")
percentage_0=$(get_tmux_option "@tmux2k-battery-percentage-0" "󰂃")
percentage_1=$(get_tmux_option "@tmux2k-battery-percentage-1" "󰁻")
percentage_2=$(get_tmux_option "@tmux2k-battery-percentage-2" "󰁽")
percentage_3=$(get_tmux_option "@tmux2k-battery-percentage-3" "󰁿")
percentage_4=$(get_tmux_option "@tmux2k-battery-percentage-4" "󰁹")
battery_gradient="$(get_tmux_option '@tmux2k-battery-gradient' '')"
battery_icon_link_to="$(get_tmux_option '@tmux2k-battery-icon-link-to' '')"

[ -n "$battery_gradient" ] &&
    source "$current_dir/../lib/color-utils.sh"

battery_info_linux() {
    local bat_path capacity status
    bat_path=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -1)

    if [ -n "$bat_path" ] && [ -f "$bat_path/capacity" ]; then
        capacity=$(cat "$bat_path/capacity" 2>/dev/null)
        status=$(cat "$bat_path/status" 2>/dev/null)
        echo "${status}|${capacity}"
    elif command -v acpi >/dev/null 2>&1; then
        status=$(acpi | cut -d: -f2- | cut -d, -f1 | tr -d ' ')
        capacity=$(acpi | cut -d: -f2- | cut -d, -f2 | tr -d '% ')
        echo "${status}|${capacity}"
    fi
}

battery_info_darwin() {
    local raw_batt status capacity
    raw_batt=$(pmset -g batt 2>/dev/null)
    capacity=$(echo "$raw_batt" | grep -Eo '[0-9]?[0-9]?[0-9]%' | tr -d '%' | head -n1)
    status=$(echo "$raw_batt" | sed -n 2p | cut -d ';' -f 2 | tr -d " ")
    echo "${status}|${capacity}"
}

battery_label() {
    local bat_perc=$1
    if [ "$bat_perc" -ge 90 ]; then
        echo "$percentage_4"
    elif [ "$bat_perc" -ge 70 ]; then
        echo "$percentage_3"
    elif [ "$bat_perc" -ge 40 ]; then
        echo "$percentage_2"
    elif [ "$bat_perc" -ge 15 ]; then
        echo "$percentage_1"
    else
        echo "$percentage_0"
    fi
}

main() {
    local info status perc icon_str=''
    case $(uname -s) in
        Linux) info=$(battery_info_linux) ;;
        Darwin) info=$(battery_info_darwin) ;;
        FreeBSD)
            perc=$(apm | sed '8,11d' | grep life | awk '{print $4}' | tr -d '%')
            status=$(apm | sed '8,11d' | grep Status | awk '{printf $3}')
            info="${status}|${perc}"
            ;;
    esac

    IFS='|' read -r status perc <<<"$info"

    if [ -z "$perc" ]; then
        echo "$battery_missing N/A"
        return
    fi

    local is_charging=false
    case "$status" in
        charging|Charging|AC|'AC Power') is_charging=true ;;
    esac

    if [ "$is_charging" = true ]; then
        icon_str="$charging_icon"
    else
        icon_str=$(battery_label "$perc")
    fi

    local color_prefix='' icon_color=''
    if [ -n "$battery_gradient" ] && [ -n "$perc" ]; then
        local color
        color="$(pct2color "${perc}%" "$battery_gradient")"
        color_prefix="#[fg=${color:-default}]"
        [ "$battery_icon_link_to" = 'usage' ] &&
            icon_color="$color_prefix"
    fi

    echo "${icon_color}${icon_str} ${color_prefix}${perc}%"
}

main
