#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir/../lib/utils.sh"

charging_icon=$(get_tmux_option "@tmux2k-battery-charging-icon" "")
battery_missing=$(get_tmux_option "@tmux2k-battery-missing-icon" "󱉝")
percentage_0=$(get_tmux_option "@tmux2k-battery-percentage-0" "")
percentage_1=$(get_tmux_option "@tmux2k-battery-percentage-1" "")
percentage_2=$(get_tmux_option "@tmux2k-battery-percentage-2" "")
percentage_3=$(get_tmux_option "@tmux2k-battery-percentage-3" "")
percentage_4=$(get_tmux_option "@tmux2k-battery-percentage-4" "")

linux_acpi() {
    arg=$1
    BAT=$(ls -d /sys/class/power_supply/BAT* | head -1)
    if [ ! -x "$(which acpi 2>/dev/null)" ]; then
        case "$arg" in
        status) cat "$BAT"/status ;;
        percent) cat "$BAT"/capacity ;;
        esac
    else
        case "$arg" in
        status) acpi | cut -d: -f2- | cut -d, -f1 | tr -d ' ' ;;
        percent) acpi | cut -d: -f2- | cut -d, -f2 | tr -d '% ' ;;
        esac
    fi
}

battery_percent() {
    case $(uname -s) in
    Linux)
        percent=$(linux_acpi percent)
        [ -n "$percent" ] && echo " $percent"
        ;;

    Darwin) echo $(pmset -g batt | grep -Eo '[0-9]?[0-9]?[0-9]%' | sed 's/%//g') ;;

    FreeBSD) echo $(apm | sed '8,11d' | grep life | awk '{print $4}') ;;

    CYGWIN* | MINGW32* | MSYS* | MINGW*) ;; # TODO - windows compatability
    esac
}

battery_status() {
    case $(uname -s) in
    Linux) status=$(linux_acpi status) ;;
    Darwin) status=$(pmset -g batt | sed -n 2p | cut -d ';' -f 2 | tr -d " ") ;;
    FreeBSD) status=$(apm | sed '8,11d' | grep Status | awk '{printf $3}') ;;
    CYGWIN* | MINGW32* | MSYS* | MINGW*) ;;
    esac

    case $status in
    discharging | Discharging) echo '' ;;
    high) echo '' ;;
    charging) echo "$charging_icon" ;;
    esac
}

battery_label() {
    if [ "$bat_perc" -gt 90 ]; then
        echo "$percentage_4 "
    elif [ "$bat_perc" -gt 75 ]; then
        echo "$percentage_3 "
    elif [ "$bat_perc" -gt 50 ]; then
        echo "$percentage_2 "
    elif [ "$bat_perc" -gt 25 ]; then
        echo "$percentage_1 "
    elif [ "$bat_perc" -gt 10 ]; then
        echo "$percentage_0 "
    else
        echo "$battery_missing "
    fi
}

main() {
    bat_stat=$(battery_status)
    bat_perc="$(battery_percent)"
    bat_label="$(battery_label)"

    if [ -z "$bat_stat" ]; then
        echo "$bat_label $bat_perc%"
    elif [ -z "$bat_perc" ]; then
        echo "$bat_stat $bat_label"
    else
        echo "$bat_stat $bat_label $bat_perc%"
    fi
}

main
