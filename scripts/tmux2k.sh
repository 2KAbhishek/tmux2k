#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir"/utils.sh

show_powerline=$(get_tmux_option "@tmux2k-show-powerline" true)
show_refresh=$(get_tmux_option "@tmux2k-refresh-rate" 60)
show_left_icon=$(get_tmux_option "@tmux2k-show-left-icon" rocket)
show_left_sep=$(get_tmux_option "@tmux2k-show-left-sep" )
show_right_sep=$(get_tmux_option "@tmux2k-show-right-sep" )
win_left_sep=$(get_tmux_option "@tmux2k-window-left-sep" )
win_right_sep=$(get_tmux_option "@tmux2k-window-right-sep" )
show_flags=$(get_tmux_option "@tmux2k-show-flags" true)
IFS=' ' read -r -a lplugins <<<"$(get_tmux_option '@tmux2k-left-plugins' 'git cpu ram')"
IFS=' ' read -r -a rplugins <<<"$(get_tmux_option '@tmux2k-right-plugins' 'battery network time')"

black='#0a0a0f',
blue='#1688f0',
cyan='#11dddd',
gray='#15152a'
green='#3dd50A',
orange='#ffb86c'
pink='#ff79c6'
purple='#BF58FF',
red='#ff001f',
white='#d5d5da'
yellow='#ffd21a',
light_cyan='#8be9fd'
light_gray='#45455a'
light_green='#50fa7b'
light_purple='#bd93f9'
light_red='#ff0055'
light_yellow='#f1fa8c'
plugin_fg='#282a36'

declare -A plugin_colors=(
    ["git"]="green plugin_fg"
    ["battery"]="pink plugin_fg"
    ["gpu"]="orange plugin_fg"
    ["cpu"]="blue plugin_fg"
    ["ram"]="yellow plugin_fg"
    ["network"]="purple plugin_fg"
    ["bandwidth"]="purple plugin_fg"
    ["ping"]="purple plugin_fg"
    ["weather"]="orange plugin_fg"
    ["time"]="cyan plugin_fg"
)

get_plugin_colors() {
    local plugin_name="$1"
    local default_colors="${plugin_colors[$plugin_name]}"
    get_tmux_option "@tmux2k-${plugin_name}-colors" "$default_colors"
}

build_status_bar() {
    side=$1
    if [ "$side" == "left" ]; then
        plugins=("${lplugins[@]}")
    else
        plugins=("${rplugins[@]}")
    fi

    for plugin_index in "${!plugins[@]}"; do
        plugin="${plugins[$plugin_index]}"
        if [ -z "${plugin_colors[$plugin]}" ]; then
            continue
        fi

        IFS=' ' read -r -a colors <<<"$(get_plugin_colors "$plugin")"
        script="#($current_dir/$plugin.sh)"

        if [ "$side" == "left" ]; then
            if $show_powerline; then
                next_plugin=${plugins[$((plugin_index + 1))]}
                IFS=' ' read -r -a next_colors <<<"$(get_plugin_colors "$next_plugin")"
                powerbg=${!next_colors[0]:-$gray}
                tmux set-option -ga status-left "#[fg=${!colors[1]},bg=${!colors[0]}] $script #[fg=${!colors[0]},bg=${powerbg},nobold,nounderscore,noitalics]${left_sep}"
                powerbg=${gray}
            else
                tmux set-option -ga status-left "#[fg=${!colors[1]},bg=${!colors[0]}] $script "
            fi
        else
            if $show_powerline; then
                tmux set-option -ga status-right "#[fg=${!colors[0]},bg=${powerbg},nobold,nounderscore,noitalics]${right_sep}#[fg=${!colors[1]},bg=${!colors[0]}] $script "
                powerbg=${!colors[0]}
            else
                tmux set-option -ga status-right "#[fg=${!colors[1]},bg=${!colors[0]}] $script "
            fi
        fi
    done
}

main() {
    case $show_left_icon in
    rocket) left_icon="" ;;
    session) left_icon="#S" ;;
    window) left_icon="#W" ;;
    *) left_icon=$show_left_icon ;;
    esac

    tmux set-option -g status-interval "$show_refresh"
    tmux set-option -g status-left-length 100
    tmux set-option -g status-right-length 100
    tmux set-option -g status-left ""
    tmux set-option -g status-right ""

    tmux set-option -g pane-active-border-style "fg=${blue}"
    tmux set-option -g pane-border-style "fg=${gray}"
    tmux set-option -g message-style "bg=${gray},fg=${blue}"
    tmux set-option -g status-style "bg=${gray},fg=${white}"
    tmux set -g status-justify absolute-centre

    tmux set-window-option -g window-status-activity-style "bold"
    tmux set-window-option -g window-status-bell-style "bold"
    tmux set-window-option -g window-status-current-style "bold"

    if $show_flags; then
        flags="#{?window_flags,#[fg=${light_red}]#{window_flags},}"
        current_flags="#{?window_flags,#[fg=${light_yellow}]#{window_flags},}"
    fi

    if $show_powerline; then
        right_sep="$show_right_sep"
        left_sep="$show_left_sep"
        tmux set-window-option -g window-status-current-format "#[fg=${blue},bg=${gray}]${win_left_sep}#[bg=${blue}]${current_flags}#[fg=${black}] #I:#W #[fg=${blue},bg=${gray}]${win_right_sep}"
        tmux set-window-option -g window-status-format "#[fg=${light_gray},bg=${gray}]${win_left_sep}#[bg=${light_gray}]${flags}#[fg=${white}] #I:#W #[fg=${light_gray},bg=${gray}]${win_right_sep}"
        tmux set-option -g status-left "#[bg=${green},fg=${plugin_fg}]#{?client_prefix,#[bg=${yellow}} ${left_icon} #[fg=${green},bg=${green}]#{?client_prefix,#[fg=${yellow}}${left_sep}"
        powerbg=${gray}
    else
        tmux set-window-option -g window-status-current-format "#[fg=${white},bg=${blue}] #I:#W ${current_flags} "
        tmux set-window-option -g window-status-format "#[fg=${white},bg=${light_gray}] #I:#W ${flags} "
        tmux set-option -g status-left "#[bg=${green},fg=${plugin_fg}]#{?client_prefix,#[bg=${yellow}],} ${left_icon}"
    fi

    build_status_bar "left"
    build_status_bar "right"
}

main
