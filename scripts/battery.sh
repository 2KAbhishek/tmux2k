#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir"/utils.sh

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
    charging) echo '' ;;
    *) echo '' ;;
    esac
}

battery_label() {
    if [ "$bat_perc" -gt 90 ]; then
        echo " "
    elif [ "$bat_perc" -gt 75 ]; then
        echo " "
    elif [ "$bat_perc" -gt 50 ]; then
        echo " "
    elif [ "$bat_perc" -gt 25 ]; then
        echo " "
    elif [ "$bat_perc" -gt 10 ]; then
        echo " "
    else
        echo "󱉝 "
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
