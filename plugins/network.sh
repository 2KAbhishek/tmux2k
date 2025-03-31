#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8

HOSTS="google.com github.com example.com"

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir/../lib/utils.sh"

ethernet_icon=$(get_tmux_option "@tmux2k-network-ethernet-icon" "󰈀")
wifi_icon=$(get_tmux_option "@tmux2k-network-wifi-icon" "")
offline_icon=$(get_tmux_option "@tmux2k-network-offline-icon" "󰌙")

get_ssid() {
    case $(uname -s) in
    Linux)
        SSID=$(iwgetid -r)
        if [ -n "$SSID" ]; then
            printf '%s' "$wifi_icon $SSID"
        else
            echo "$ethernet_icon Eth"
        fi
        ;;

    Darwin)
        device_name=$(networksetup -listallhardwareports | grep -A 1 Wi-Fi | grep Device | awk '{print $2}')
        # SSID=$(ioreg -l | awk -F\" '/SSID/{if ($4 != "") print $4}' | grep -v 'IOReportGroupName')
        SSID=$(networksetup -getairportnetwork "$device_name" | awk -F ": " '{print $2}')
        if [ -n "$SSID" ]; then
            printf '%s' "$wifi_icon $SSID"
        else
            echo "$ethernet_icon Eth"
        fi
        ;;

    CYGWIN* | MINGW32* | MSYS* | MINGW*) ;; # TODO - windows compatibility
    esac
}

main() {
    network="$offline_icon Offline"
    for host in $HOSTS; do
        if ping -q -c 1 -W 1 "$host" &>/dev/null; then
            network="$(get_ssid)"
            break
        fi
    done

    echo "$network"
}

main
