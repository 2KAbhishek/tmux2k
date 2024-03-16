#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir"/utils.sh

get_platform() {
    case $(uname -s) in
    Linux)
        gpu=$(lspci -v | grep VGA | head -n 1 | awk '{print $5}')
        echo "$gpu"
        ;;
    Darwin) ;; # TODO - Darwin/Mac compatibility
    CYGWIN* | MINGW32* | MSYS* | MINGW*) ;; # TODO - windows compatibility
    esac
}

get_gpu() {
    gpu=$(get_platform)
    if [[ "$gpu" == NVIDIA ]]; then
        usage=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | awk '{ sum += $0 } END { printf("%s%%\n", sum / NR) }')
    else
        usage='unknown'
    fi
    normalize_padding "$usage"
}

main() {
    RATE=$(get_tmux_option "@tmux2k-refresh-rate" 5)
    gpu_label=$(get_tmux_option "@tmux2k-gpu-usage-label" "GPU")
    gpu_usage=$(get_gpu)
    echo "$gpu_label $gpu_usage"
    sleep "$RATE"
}

main
