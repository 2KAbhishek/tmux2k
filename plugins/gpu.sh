#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir/../lib/utils.sh"

gpu_gradient="$(get_tmux_option '@tmux2k-gpu-gradient' '')"

[ -n "$gpu_gradient" ] &&
    source "$current_dir/../lib/color-utils.sh"

gpu_icon_link_to="$(get_tmux_option '@tmux2k-gpu-icon-link-to' '')"

get_platform() {
    case $(uname -s) in
    Linux)
        gpu=$(lspci -v | grep VGA | head -n 1 | awk '{print $5}')
        echo "$gpu"
        ;;
    Darwin) echo "Apple" ;;
    CYGWIN* | MINGW32* | MSYS* | MINGW*) ;; # TODO - windows compatibility
    esac
}

get_gpu() {
    local gpu usage
    gpu=$(get_platform)

    case "$gpu" in
    NVIDIA)
        usage=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | awk '{ sum += $0 } END { printf("%s", sum / NR) }')
        ;;
    Apple)
        usage=$(ioreg -l 2>/dev/null | grep "PerformanceStatistics" | grep "Device Utilization" | sed -n 's/.*"Device Utilization %"=\([0-9]*\).*/\1/p' | head -1)
        ;;
    esac

    if [ -z "$usage" ]; then
        normalize_padding 'N/A'
        return
    fi

    local output=''
    if [ -n "$gpu_gradient" ]; then
        local color
        color="$(pct2color "${usage}%" "$gpu_gradient")"
        output+="#[fg=${color:-default}]"
        [ "$gpu_icon_link_to" = 'usage' ] &&
            tmux set -g '@tmux2k-gpu-linked-color' "$color"
    fi
    output+="$(normalize_padding "${usage}%")"
    printf '%s' "$output"
}

main() {
    local gpu_icon gpu_usage output=''
    gpu_icon=$(get_tmux_option "@tmux2k-gpu-icon" "")
    gpu_usage=$(get_gpu)

    if [ -z "$gpu_icon_link_to" ] || [ -z "$gpu_gradient" ]; then
        tmux set -g '@tmux2k-gpu-linked-color' ''
    else
        local gpu_linked_color
        gpu_linked_color="$(get_tmux_option '@tmux2k-gpu-linked-color' '')"
        [ -n "$gpu_linked_color" ] &&
            output+="#[fg=${gpu_linked_color}]"
    fi

    output+="$gpu_icon $gpu_usage"
    printf '%s' "$output"
}

main
