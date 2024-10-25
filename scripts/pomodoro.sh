#!/usr/bin/env bash

if [ -z "$TMUX" ]; then
    echo "No tmux session."
    exit 1
fi

# Check for olimorris/tmux-pomodoro-plus scripts
POMODORO_SCRIPT="$HOME/.tmux/plugins/tmux-pomodoro-plus/scripts/pomodoro.sh"
POMODORO_HELPER="$HOME/.tmux/plugins/tmux-pomodoro-plus/scripts/helpers.sh"

if [ -f "$POMODORO_SCRIPT" ]; then
    . "$POMODORO_SCRIPT"
    . "$POMODORO_HELPER"
fi

main() {
    pomodoro_status="$(pomodoro_status)"
    RATE=$(get_tmux_option "@tmux2k-ping-rate" 5)
    sleep "$RATE"
}

main
