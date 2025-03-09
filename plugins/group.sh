#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir/../lib/utils.sh"

main() {
    scripts=$(get_tmux_option "@tmux2k-group-plugins" "cpu ram uptime")
    delimiter=$(get_tmux_option "@tmux2k-group-delimiter" "")
    val=""
    for script in $scripts; do
        sname="${current_dir}/${script}.sh"
        val+="$($sname)"
        val+=$delimiter
    done
    size=${#val}
    let "size = size-1"
    val=${val:0:size}
    echo -n "$val"
}

main
