#!/usr/bin/env bash

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir/../lib/utils.sh"

get_pane_dir() {
    nextone="false"
    ret=""
    for i in $(tmux list-panes -F "#{pane_active} #{pane_current_path}"); do
        [ "$i" == "1" ] && nextone="true" && continue
        [ "$i" == "0" ] && nextone="false"
        [ "$nextone" == "true" ] && ret+="$i "
    done
    echo "${ret%?}"
}

truncate_path() {
    local path="$1"
    local max_length=$(get_tmux_option "@tmux2k-cwd-length" 40)
    local min_depth=$(get_tmux_option "@tmux2k-cwd-min-depth" 4)
    local prefix_chars=$(get_tmux_option "@tmux2k-cwd-prefix-chars" 2)

    [[ ${#path} -le $max_length ]] && echo "$path" && return

    IFS='/' read -ra parts <<<"$path"
    local truncated=""

    for ((i = 0; i < ${#parts[@]} - 1; i++)); do
        truncated+="${parts[i]:0:$prefix_chars}/"
    done
    truncated+="${parts[-1]}"

    [[ ${#truncated} -le $max_length ]] && echo "$truncated" && return

    local slash_count=$(tr -cd '/' <<<"$truncated" | wc -c)
    if [[ $slash_count -gt $min_depth ]]; then
        IFS='/' read -ra parts <<<"$truncated"
        echo "${parts[0]}/${parts[1]}/.../${parts[-2]}/${parts[-1]}"
    else
        echo "$truncated"
    fi
}

main() {
    path=$(get_pane_dir)

    cwd="${path/"$HOME"/'~'}"
    truncated_cwd=$(truncate_path "$cwd")
    cwd_icon=$(get_tmux_option "@tmux2k-cwd-icon" "")

    echo "$cwd_icon $truncated_cwd"
}

main
