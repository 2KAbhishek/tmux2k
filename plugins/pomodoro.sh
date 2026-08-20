#!/usr/bin/env bash

if [ -z "$TMUX" ]; then
    echo "No tmux session."
    exit 1
fi

# Check for olimorris/tmux-pomodoro-plus scripts
current_dir="${BASH_SOURCE[0]%/*}"
[ "$current_dir" = "${BASH_SOURCE[0]}" ] && current_dir="."
source "$current_dir/../lib/utils.sh"
POMODORO_SCRIPT="$current_dir/../../tmux-pomodoro-plus/scripts/pomodoro.sh"
POMODORO_HELPER="$current_dir/../../tmux-pomodoro-plus/scripts/helpers.sh"

if [ -f "$POMODORO_SCRIPT" ]; then
    . "$POMODORO_SCRIPT"
    . "$POMODORO_HELPER"
fi

main() {
    if declare -f pomodoro_status >/dev/null 2>&1; then
        pomodoro_status="$(pomodoro_status)"
    else
        pomodoro_status=""
    fi
}

main
