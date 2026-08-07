#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir/../lib/utils.sh"

ram_gradient="$(get_tmux_option '@tmux2k-ram-gradient' '')"

[ -n "$ram_gradient" ] &&
    source "$current_dir/../lib/color-utils.sh"

ram_icon_link_to="$(get_tmux_option '@tmux2k-ram-icon-link-to' '')"

get_ram_info() {
    local percent='' used_gb='' total_gb='' free_gb=''
    local display
    display=$(get_tmux_option "@tmux2k-ram-display" "percent")
    precision=$(get_tmux_option "@tmux2k-ram-precision" "0")

    case $(uname -s) in
    Linux)
        local total_mb used_mb free_mb
        total_mb=$(LC_ALL=C free -m | awk '/^Mem/ {print $2}')
        used_mb=$(LC_ALL=C free -m | awk '/^Mem/ {print $3}')
        free_mb=$(LC_ALL=C free -m | awk '/^Mem/ {print $4}')

        if [ -n "$total_mb" ] && [ "$total_mb" -gt 0 ]; then
            percent=$(awk -v u="$used_mb" -v t="$total_mb" -v p="$precision" 'BEGIN {printf "%.*f", p, (u * 100) / t}')
        fi

        used_gb=$(awk -v m="$used_mb" 'BEGIN {printf "%.1fG", m/1024}')
        total_gb=$(awk -v m="$total_mb" 'BEGIN {printf "%.1fG", m/1024}')
        free_gb=$(awk -v m="$free_mb" 'BEGIN {printf "%.1fG", m/1024}')
        ;;

    Darwin)
        local used_mb total_mb free_mb pagesize_val
        pagesize_val=$(pagesize 2>/dev/null || sysctl -n hw.pagesize 2>/dev/null || echo 4096)
        used_mb=$(vm_stat | awk -v ps="$pagesize_val" '/Pages active|Pages wired/ {sum += $NF} END {print int(sum * ps / 1048576)}')
        total_mb=$(sysctl -n hw.memsize 2>/dev/null | awk '{print int($1 / 1048576)}')

        [ -z "$total_mb" ] && total_mb=1

        free_mb=$((total_mb - used_mb))
        percent=$(((used_mb * 100) / total_mb))

        used_gb=$(awk -v m="$used_mb" 'BEGIN {printf "%.1fG", m/1024}')
        total_gb=$(awk -v m="$total_mb" 'BEGIN {printf "%.1fG", m/1024}')
        free_gb=$(awk -v m="$free_mb" 'BEGIN {printf "%.1fG", m/1024}')
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

        used_gb=$(awk -v m="$used_mem" 'BEGIN {printf "%.1fG", m/1024}')
        total_gb=$(awk -v m="$total_mem" 'BEGIN {printf "%.1fG", m/1024}')
        free_gb=$(awk -v m="$free_mem" 'BEGIN {printf "%.1fG", m/1024}')
        ;;
    esac

    [ -z "$percent" ] && return

    local text_val=''
    case "$display" in
    free)
        text_val="${free_gb}"
        ;;
    used)
        text_val="${used_gb}"
        ;;
    used_total)
        text_val="${used_gb}/${total_gb}"
        ;;
    percent | *)
        text_val="${percent}%"
        ;;
    esac

    local output=''
    if [ -n "$ram_gradient" ]; then
        local color
        color="$(pct2color "${percent}%" "$ram_gradient")"
        output+="#[fg=${color:-default}]"
        [ "$ram_icon_link_to" = 'usage' ] &&
            set_state ram-linked-color "$color"
    fi
    output+="${text_val}"
    printf '%s' "$output"
}

main() {
    local ram_icon ram_info output=''
    ram_icon=$(get_tmux_option "@tmux2k-ram-icon" "")
    ram_info=$(get_ram_info)

    if [ -z "$ram_icon_link_to" ] || [ -z "$ram_gradient" ]; then
        set_state ram-linked-color ''
    else
        local ram_linked_color
        ram_linked_color="$(get_state ram-linked-color '')"
        [ -n "$ram_linked_color" ] &&
            output+="#[fg=${ram_linked_color}]"
    fi

    output+="$ram_icon $ram_info"
    printf '%s' "$output"
}

main
