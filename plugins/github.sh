#!/usr/bin/env bash

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir/../lib/utils.sh"

verify_gh_command() {
    if ! command -v gh >/dev/null 2>&1; then
        echo "$icon gh missing"
        return 1
    fi
    return 0
}

get_notification_count() {
    local count

    count=$(gh api notifications --paginate --jq 'length' 2>/dev/null | awk '{sum += $1} END {print sum+0}')

    if [ -z "$count" ] || ! [[ "$count" =~ ^[0-9]+$ ]]; then
        count=0
    fi

    echo "$count"
}

main() {
    local icon notification_count output
    icon=$(get_tmux_option "@tmux2k-github-icon" "")

    if ! verify_gh_command; then
        echo "$icon gh missing"
        return
    fi

    notification_count=$(get_notification_count)
    output="$icon $notification_count"
    echo "$output"
}

main
