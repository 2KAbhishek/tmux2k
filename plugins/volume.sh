#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8

current_dir="${BASH_SOURCE[0]%/*}"
[ "$current_dir" = "${BASH_SOURCE[0]}" ] && current_dir="."
source "$current_dir/../lib/utils.sh"

get_volume_info() {
    local vol='' muted=''

    case $(uname -s) in
    Linux)
        if command -v pactl >/dev/null 2>&1; then
            muted=$(pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | awk '{print $2}')
            vol=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | awk -F'/' '{print $2}' | tr -d ' %' | head -n1)
        elif command -v amixer >/dev/null 2>&1; then
            vol=$(amixer get Master 2>/dev/null | grep -oE '[0-9]+%' | tr -d '%' | head -n1)
            muted=$(amixer get Master 2>/dev/null | grep -o '\[off\]' | head -n1)
            [ -n "$muted" ] && muted="yes" || muted="no"
        elif command -v wpctl >/dev/null 2>&1; then
            vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{print int($2 * 100)}')
            muted=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | grep -o 'MUTED')
            [ -n "$muted" ] && muted="yes" || muted="no"
        fi
        ;;

    Darwin)
        if command -v osascript >/dev/null 2>&1; then
            vol=$(osascript -e 'output volume of (get volume settings)' 2>/dev/null)
            local is_muted
            is_muted=$(osascript -e 'output muted of (get volume settings)' 2>/dev/null)
            [ "$is_muted" = "true" ] && muted="yes" || muted="no"
        fi
        ;;
    esac

    if [ "$muted" = "yes" ] || [ "$muted" = "true" ]; then
        printf 'muted|0'
    else
        [ -z "$vol" ] && vol=0
        printf 'active|%s' "$vol"
    fi
}

main() {
    local single_icon icon_muted icon_low icon_med icon_high icon output=''
    single_icon=$(get_tmux_option "@tmux2k-volume-icon" "")
    icon_muted=$(get_tmux_option "@tmux2k-volume-icon-muted" "󰖁")
    icon_low=$(get_tmux_option "@tmux2k-volume-icon-low" "")
    icon_med=$(get_tmux_option "@tmux2k-volume-icon-med" "󰖀")
    icon_high=$(get_tmux_option "@tmux2k-volume-icon-high" "")

    local vol_data status vol_val
    vol_data=$(get_volume_info)
    IFS='|' read -r status vol_val <<<"$vol_data"

    if [ "$status" = "muted" ]; then
        icon="${single_icon:-$icon_muted}"
        output="$icon Muted"
    else
        if [ -n "$single_icon" ]; then
            icon="$single_icon"
        elif [ "$vol_val" -ge 70 ]; then
            icon="$icon_high"
        elif [ "$vol_val" -ge 30 ]; then
            icon="$icon_med"
        else
            icon="$icon_low"
        fi
        output="$icon ${vol_val}%"
    fi

    printf '%s' "$output"
}

main
