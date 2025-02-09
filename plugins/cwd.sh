#!/usr/bin/env bash

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir/../lib/utils.sh"

# return current working directory of tmux pane
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

# truncate the path if it's longer than 30 characters
truncate_path() {
    local path="$1" limit=20 truncated_path=""

    # If path is greater than limit, then truncate parts to 2 characters
    [[ ${#path} -le $limit ]] && echo "$path" && return
    IFS='/' read -ra parts <<<"$path"
    for ((i = 0; i < ${#parts[@]} - 1; i++)); do
        truncated_path+="${parts[i]:0:2}/"
    done
    truncated_path+="${parts[-1]}"

    # If there are more than 4 slashes, then we will truncate the middle part
    if [[ $(tr -cd '/' <<<"$truncated_path" | wc -c) -gt 4 ]]; then
        IFS='/' read -ra parts <<<"$truncated_path"
        echo "${parts[0]}/${parts[1]}/.../${parts[-2]}/${parts[-1]}"
    else
        echo "$truncated_path"
    fi
}

main() {
    path=$(get_pane_dir)

    # Change '/home/user' to '~'
    cwd="${path/"$HOME"/'~'}"
    truncated_cwd=$(truncate_path "$cwd")
    cwd_icon=$(get_tmux_option "@tmux2k-ram-icon" "")

    echo "$cwd_icon $truncated_cwd"
}

#run main driver program
main
