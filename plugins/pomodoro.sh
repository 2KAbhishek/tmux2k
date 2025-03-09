#!/usr/bin/env bash

if [ -z "$TMUX" ]; then
    echo "No tmux session."
    exit 1
fi

# Check for olimorris/tmux-pomodoro-plus scripts
current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
POMODORO_SCRIPT="$current_dir/../../tmux-pomodoro-plus/scripts/pomodoro.sh"
POMODORO_HELPER="$current_dir/../../tmux-pomodoro-plus/scripts/helpers.sh"

if [ -f "$POMODORO_SCRIPT" ]; then
    . "$POMODORO_SCRIPT"
    . "$POMODORO_HELPER"
fi

main() {
    pomodoro_status="$(pomodoro_status)"
}

main
