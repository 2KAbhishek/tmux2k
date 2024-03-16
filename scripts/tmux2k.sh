#!/usr/bin/env bash
# setting the locale, some users have issues with different locales, this forces the correct one
export LC_ALL=en_US.UTF-8

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir"/utils.sh

# set configuration option variables
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

white='#d5d5da'
black='#0a0a0f',
gray='#15152a'
red='#ff001f',
green='#3dd50A',
yellow='#ffd21a',
blue='#1688f0',
purple='#BF58FF',
cyan='#11dddd',
orange='#ffb86c'
pink='#ff79c6'
light_purple='#bd93f9'
light_cyan='#8be9fd'
light_green='#50fa7b'
light_red='#ff0055'
light_yellow='#f1fa8c'
dark_gray='#282a36'
light_gray='#45455a'
dark_gray='#282a36'

declare -A plugin_colors=(
    ["git"]="green dark_gray"
    ["battery"]="pink dark_gray"
    ["gpu"]="orange dark_gray"
    ["cpu"]="blue dark_gray"
    ["ram"]="yellow dark_gray"
    ["network"]="purple dark_gray"
    ["bandwidth"]="purple dark_gray"
    ["ping"]="purple dark_gray"
    ["weather"]="orange dark_gray"
    ["time"]="cyan dark_gray"
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
    rocket)
        left_icon=""
        ;;
    session)
        left_icon="#S"
        ;;
    window)
        left_icon="#W"
        ;;
    *)
        left_icon=$show_left_icon
        ;;
    esac

    # sets refresh interval to every 5 seconds
    tmux set-option -g status-interval "$show_refresh"

    # set length
    tmux set-option -g status-left-length 100
    tmux set-option -g status-right-length 100
    tmux set-option -g status-left ""
    tmux set-option -g status-right ""

    # message styling
    tmux set-option -g pane-active-border-style "fg=${blue}"
    tmux set-option -g pane-border-style "fg=${gray}"
    tmux set-option -g message-style "bg=${gray},fg=${blue}"
    tmux set-option -g status-style "bg=${gray},fg=${white}"
    tmux set -g status-justify absolute-centre

    tmux set-window-option -g window-status-activity-style "bold"
    tmux set-window-option -g window-status-bell-style "bold"
    tmux set-window-option -g window-status-current-style "bold"
    # Window option
    case $show_flags in
    false)
        flags=""
        current_flags=""
        ;;
    true)
        flags="#{?window_flags,#[fg=${light_purple}]#{window_flags},}"
        current_flags="#{?window_flags,#[fg=${light_red}]#{window_flags},}"
        ;;
    esac

    if $show_powerline; then
        right_sep="$show_right_sep"
        left_sep="$show_left_sep"
        tmux set-window-option -g window-status-current-format "#[fg=${blue},bg=${gray}]${win_left_sep}#[bg=${blue}]${current_flags}#[fg=${black}] #I:#W #[fg=${blue},bg=${gray}]${win_right_sep}"
        tmux set-window-option -g window-status-format "#[fg=${light_gray},bg=${gray}]${win_left_sep}#[bg=${light_gray}]${flags}#[fg=${white}] #I:#W #[fg=${light_gray},bg=${gray}]${win_right_sep}"
        tmux set-option -g status-left "#[bg=${green},fg=${dark_gray}]#{?client_prefix,#[bg=${yellow}} ${left_icon} #[fg=${green},bg=${green}]#{?client_prefix,#[fg=${yellow}}${left_sep}"
        powerbg=${gray}
    else
        tmux set-window-option -g window-status-current-format "#[fg=${white},bg=${blue}] #I:#W ${current_flags} "
        tmux set-window-option -g window-status-format "#[fg=${white},bg=${light_gray}] #I:#W ${flags} "
        tmux set-option -g status-left "#[bg=${green},fg=${dark_gray}]#{?client_prefix,#[bg=${yellow}],} ${left_icon}"
    fi

    build_status_bar "left"
    build_status_bar "right"
}

# run main function
main
