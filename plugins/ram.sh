#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir/../lib/utils.sh"

ram_gradient="$(get_tmux_option '@tmux2k-ram-gradient' '')"

[ -n "$ram_gradient" ] &&
    source "$current_dir/../lib/color-utils.sh"

ram_icon_link_to="$(get_tmux_option '@tmux2k-ram-icon-link-to' '')"

get_percent() {
    local percent=''
    case $(uname -s) in
    Linux)
        local total_mem used_mem
        total_mem=$(LC_ALL=C free -m | awk '/^Mem/ {print $2}')
        used_mem=$(LC_ALL=C free -m | awk '/^Mem/ {print $3}')
        percent=$(((used_mem * 100) / total_mem))
        ;;
    Darwin)
        local used_mem total_mem
        used_mem=$(vm_stat | grep ' active\|wired ' | sed 's/[^0-9]//g' | paste -sd ' ' - | awk -v pagesize=$(pagesize) '{printf "%d\n", ($1+$2) * pagesize / 1048576}')
        total_mem=$(system_profiler SPHardwareDataType | grep "Memory:" | awk '{print $2}')
        percent=$(((used_mem) / total_mem / 10))
        ;;
    FreeBSD)
        local hw_pagesize mem_inactive mem_unused mem_cache free_mem total_mem used_mem
        hw_pagesize="$(sysctl -n hw.pagesize)"
        mem_inactive="$(($(sysctl -n vm.stats.vm.v_inactive_count) * hw_pagesize))"
        mem_unused="$(($(sysctl -n vm.stats.vm.v_free_count) * hw_pagesize))"
        mem_cache="$(($(sysctl -n vm.stats.vm.v_cache_count) * hw_pagesize))"
        free_mem=$(((mem_inactive + mem_unused + mem_cache) / 1024 / 1024))
        total_mem=$(($(sysctl -n hw.physmem) / 1024 / 1024))
        used_mem=$((total_mem - free_mem))
        percent=$(((used_mem * 100) / total_mem))
        ;;
    CYGWIN* | MINGW32* | MSYS* | MINGW*) ;; # TODO - windows compatibility
    esac

    [ -z "$percent" ] && return

    local output=''
    if [ -n "$ram_gradient" ]; then
        local color
        color="$(pct2color "${percent}%" "$ram_gradient")"
        output+="#[fg=${color:-default}]"
        [ "$ram_icon_link_to" = 'usage' ] &&
            tmux set -g '@tmux2k-ram-linked-color' "$color"
    fi
    output+="$(normalize_padding "${percent}%")"
    printf '%s' "$output"
}

main() {
    local ram_icon ram_percent output=''
    ram_icon=$(get_tmux_option "@tmux2k-ram-icon" "")
    ram_percent=$(get_percent)

    if [ -z "$ram_icon_link_to" ] || [ -z "$ram_gradient" ]; then
        tmux set -g '@tmux2k-ram-linked-color' ''
    else
        local ram_linked_color
        ram_linked_color="$(get_tmux_option '@tmux2k-ram-linked-color' '')"
        [ -n "$ram_linked_color" ] &&
            output+="#[fg=${ram_linked_color}]"
    fi

    output+="$ram_icon $ram_percent"
    printf '%s' "$output"
}

main
