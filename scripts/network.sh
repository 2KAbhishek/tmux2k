#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8

HOSTS="google.com github.com example.com"

get_ssid() {
    case $(uname -s) in
    Linux)
        SSID=$(iwgetid -r)
        if [ -n "$SSID" ]; then
            printf '%s' " $SSID"
        else
            echo '󰈀 Ethernet'
        fi
        ;;

    Darwin)
        if /System/Library/PrivateFrameworks/Apple80211.framework/Resources/airport -I | grep -E ' SSID' | cut -d ':' -f 2 | sed 's/ ^*//g' &>/dev/null; then
            SSID="$(/System/Library/PrivateFrameworks/Apple80211.framework/Resources/airport -I | grep -E ' SSID' | cut -d ':' -f 2)"
            printf '%s' " $SSID"
        else
            echo '󰈀 Ethernet'
        fi
        ;;

    CYGWIN* | MINGW32* | MSYS* | MINGW*) ;; # TODO - windows compatability
    esac
}

main() {
    network="Offline"
    for host in $HOSTS; do
        if ping -q -c 1 -W 1 "$host" &>/dev/null; then
            network="$(get_ssid)"
            break
        fi
    done

    echo "$network"
}

main
