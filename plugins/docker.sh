#!/usr/bin/env bash

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir/../lib/utils.sh"

main() {
    docker_icon=$(get_tmux_option "@tmux2k-docker-icon" "")
    docker_grep=$(get_tmux_option "@tmux2k-docker-grep")

    if ! docker images >/dev/null 2>&1; then
        echo "$docker_icon "
        return
    fi

    if [[ -z "${docker_grep}" ]]; then
        container_count=$(docker container ls | tail -n +2 | wc -l)
    else
        container_count=$(docker container ls | grep -c "${docker_grep}")
    fi
    if [ "${container_count}" -eq 0 ]; then
        echo "$docker_icon 0"
        return
    fi

    echo "$docker_icon ${container_count}"
}

main
