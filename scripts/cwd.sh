#!/usr/bin/env bash

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
    local path="$1"
    local limit=30

    if [ ${#path} -gt $limit ]; then
        # Split the path into an array by '/'
        IFS='/' read -r -a path_array <<<"$path"
        truncated_path=""

        for ((i = 0; i < ${#path_array[@]} - 1; i++)); do
            if [ ${#path_array[i]} -gt 1 ]; then
                truncated_path+="${path_array[i]:0:1}/"
            else
                truncated_path+="${path_array[i]}/"
            fi
        done

        # Add the last component of the current directory path
        truncated_path+="${path_array[-1]}"

        echo "$truncated_path"
    else
        echo "$path"
    fi
}

main() {
    path=$(get_pane_dir)

    # change '/home/user' to '~'
    cwd="${path/"$HOME"/'~'}"

    # Truncate path if it's too long
    truncated_cwd=$(truncate_path "$cwd")

    echo " $truncated_cwd"
}

#run main driver program
main
