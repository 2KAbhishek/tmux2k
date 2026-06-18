#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8

HOSTS="google.com github.com example.com"

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir/../lib/utils.sh"

ethernet_icon=$(get_tmux_option "@tmux2k-network-ethernet-icon" "󰈀")
wifi_icon=$(get_tmux_option "@tmux2k-network-wifi-icon" "")
offline_icon=$(get_tmux_option "@tmux2k-network-offline-icon" "󰌙")

get_ssid() {
    local SSID=""
    case $(uname -s) in
    Linux)
        if command -v nmcli >/dev/null; then
            SSID=$(nmcli connection show --active|awk '/wifi/{print $1}')
        elif command -v iwgetid >/dev/null 2>&1; then
            SSID=$(iwgetid -r)
        else
            local wlaninfo
            if wlaninfo=$(iw wlan0 link 2>/dev/null); then
                SSID=$(awk -F ':' '/SSID/{print $2}' <<< "${wlaninfo}")
            fi
        fi
        if [ -n "$SSID" ]; then
            printf '%s' "$wifi_icon $SSID"
        else
            echo "$ethernet_icon Eth"
        fi
        ;;

    Darwin)
        local device_name SSID
        device_name=$(networksetup -listallhardwareports 2>/dev/null | grep -A 1 Wi-Fi | grep Device | awk '{print $2}')
        if [ -n "$device_name" ]; then
            SSID=$(networksetup -listpreferredwirelessnetworks "$device_name" 2>/dev/null | sed -n '2s/^\t//p')
        fi
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
    local network="$offline_icon Offline"
    local host
    for host in $HOSTS; do
        if ping -q -c 1 -W 1 "$host" &>/dev/null; then
            network="$(get_ssid)"
            break
        fi
    done

    echo "$network"
}

main
