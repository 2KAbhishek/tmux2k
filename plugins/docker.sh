#!/usr/bin/env bash

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir/../lib/utils.sh"


main() {
    docker images >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "  "
        return
    fi

    docker_mode=$(get_tmux_option "@tmux2k-docker-mode" "containers")

    if [[ "${docker_mode}" == "containers" ]]; then
        container_num=$(docker container ls | wc -l | tr -d ' ')
        if [ "${container_num}" -le 1 ]; then
            echo " "
            return
        fi

        echo "  $(expr ${container_num} - 1)"
    elif [[ "${docker_mode}" == "grep" ]]; then
        docker_grep=$(get_tmux_option "@tmux2k-docker-grep")
        docker_label=$(get_tmux_option "@tmux2k-docker-label")

        docker container ls | grep ${docker_grep} >/dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo " "
            return
        fi

        echo "  [${docker_label}]"
    fi
}

main
