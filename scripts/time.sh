#!/usr/bin/env bash
export LC_ALL=en_US.UTF-8

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir"/utils.sh

show_military=$(get_tmux_option "@tmux2k-military-time" false)
show_timezone=$(get_tmux_option "@tmux2k-show-timezone" false)
show_day_month=$(get_tmux_option "@tmux2k-day-month" false)

get_timezone() {
    if $show_timezone; then
        date +"%Z "
    fi
}

main() {
    timezone=$(get_timezone)

    if $show_military; then
        tmux set-option -g clock-mode-style 24
    else
        tmux set-option -g clock-mode-style 12
    fi

    if $show_day_month && $show_military; then
        date +" %a %d/%m %R ${timezone}"
    elif $show_military; then
        date +" %a %m/%d %R ${timezone}"
    elif $show_day_month; then
        date +" %a %b %d %I:%M %p ${timezone}"
    else
        date +" %a %I:%M %p ${timezone}"
    fi
}

main
