#!/usr/bin/env bash
# setting the locale, some users have issues with different locales, this forces the correct one
export LC_ALL=en_US.UTF-8

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir"/utils.sh

get_platform() {
    case $(uname -s) in
    Linux)
        gpu=$(lspci -v | grep VGA | head -n 1 | awk '{print $5}')
        echo "$gpu"
        ;;

    Darwin)
        # TODO - Darwin/Mac compatability
        ;;

    CYGWIN* | MINGW32* | MSYS* | MINGW*)
        # TODO - windows compatability
        ;;
    esac
}

get_gpu_ram() {
    gpu=$(get_platform)
    if [[ "$gpu" == NVIDIA ]]; then
        used=$(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits | awk '{ sum += $0 } END { printf("%d", sum / 1024) }')
        total=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits | awk '{ sum += $0 } END { printf("%d", sum / 1024) }')
        echo $used\G\B/$total\G\B
    else
        echo 'unknown'
    fi
}

main() {
    # storing the refresh rate in the variable RATE, default is 5
    RATE=$(get_tmux_option "@tmux2k-refresh-rate" 5)
    gpu_memory_label=$(get_tmux_option "@tmux2k-gpu-memory-label" "")
    gpu_ram=$(get_gpu_ram)
    echo "$gpu_memory_label $gpu_ram"
    sleep "$RATE"
}

# run the main driver
main
