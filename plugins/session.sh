#!/usr/bin/env bash

current_dir="${BASH_SOURCE[0]%/*}"
[ "$current_dir" = "${BASH_SOURCE[0]}" ] && current_dir="."
source "$current_dir/../lib/utils.sh"

session_icon=$(get_tmux_option "@tmux2k-session-icon" "")
session_format=$(get_tmux_option "@tmux2k-session-format" "#S") # `#W` for window
session_dynamic_colors=$(get_tmux_option "@tmux2k-session-dynamic-colors" "")

[ -n "$session_dynamic_colors" ] &&
    source "$current_dir/../lib/color-utils.sh"

main() {
    local session_name
    session_name=$(tmux display-message -p "$session_format" 2>/dev/null)
    [ -z "$session_name" ] && session_name="$session_format"

    local color_prefix=""
    if [ -n "$session_dynamic_colors" ]; then
        local color=""
        match_dynamic_color "$session_name" "$session_dynamic_colors" color
        [ -n "$color" ] && color_prefix="#[fg=${color}]"
    fi

    echo "${color_prefix}${session_icon} ${session_name}"
}

main
