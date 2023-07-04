#!/usr/bin/env bash
# setting the locale, some users have issues with different locales, this forces the correct one
export LC_ALL=en_US.UTF-8

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir"/utils.sh

get_gpu_ram() {
    if [[ "$gpu" == NVIDIA ]]; then
        used=$(nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader,nounits | awk '{ sum += $0 } END { printf("%d\n", sum / 1024) }')
        total=$(nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader,nounits | awk '{ sum += $1 } END { printf("%d\n", sum / 1024) }')
    else
        usage='unknown'
    fi
    echo $used\G\B/$total\G\B
}

main() {
    # storing the refresh rate in the variable RATE, default is 5
    RATE=$(get_tmux_option "@tmux2k-refresh-rate" 5)
    gpu_label=$(get_tmux_option "@tmux2k-gpu-memory-label" "VRAM")
    gpu_ram=$(get_gpu_ram)
    echo "$gpu_label $gpu_ram"
    sleep "$RATE"
}

# run the main driver
main
