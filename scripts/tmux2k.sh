#!/usr/bin/env bash
# setting the locale, some users have issues with different locales, this forces the correct one
export LC_ALL=en_US.UTF-8

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir"/utils.sh

main() {
    datafile=/tmp/.tmux2k-data

    # set configuration option variables
    show_fahrenheit=$(get_tmux_option "@tmux2k-show-fahrenheit" false)
    show_location=$(get_tmux_option "@tmux2k-show-location" false)
    fixed_location=$(get_tmux_option "@tmux2k-fixed-location")
    show_powerline=$(get_tmux_option "@tmux2k-show-powerline" true)
    show_flags=$(get_tmux_option "@tmux2k-show-flags" true)
    show_left_icon=$(get_tmux_option "@tmux2k-show-left-icon" rocket)
    show_left_icon_padding=$(get_tmux_option "@tmux2k-left-icon-padding" 0)
    show_military=$(get_tmux_option "@tmux2k-military-time" true)
    show_timezone=$(get_tmux_option "@tmux2k-show-timezone" false)
    show_left_sep=$(get_tmux_option "@tmux2k-show-left-sep" )
    show_right_sep=$(get_tmux_option "@tmux2k-show-right-sep" )
    show_border_contrast=$(get_tmux_option "@tmux2k-border-contrast" true)
    show_day_month=$(get_tmux_option "@tmux2k-day-month" false)
    show_refresh=$(get_tmux_option "@tmux2k-refresh-rate" 5)
    IFS=' ' read -r -a rplugins <<<"$(get_tmux_option '@tmux2k-right-plugins' 'battery network time')"
    IFS=' ' read -r -a lplugins <<<"$(get_tmux_option '@tmux2k-left-plugins' 'git cpu-usage ram-usage')"

    # tmux2k Color Pallette
    white='#d5d5da'
    black='#0a0a0f',
    gray='#25253a'
    red='#ff001f',
    green='#11d116',
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

    # Handle left icon configuration
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

    # Handle left icon padding
    padding=""
    if [ "$show_left_icon_padding" -gt "0" ]; then
        padding="$(printf '%*s' $show_left_icon_padding)"
    fi
    left_icon="$left_icon$padding"

    # Handle powerline option
    if $show_powerline; then
        right_sep="$show_right_sep"
        left_sep="$show_left_sep"
    fi

    # start weather script in background
    if [[ "${rplugins[@]}" =~ "weather" ]]; then
        "$current_dir"/sleep_weather.sh "$show_fahrenheit" "$show_location" "$fixed_location" &
    fi

    # Set timezone unless hidden by configuration
    case $show_timezone in
    false)
        timezone=""
        ;;
    true)
        timezone="#(date +%Z)"
        ;;
    esac

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

    # sets refresh interval to every 5 seconds
    tmux set-option -g status-interval "$show_refresh"

    # set the prefix + t time format
    if $show_military; then
        tmux set-option -g clock-mode-style 24
    else
        tmux set-option -g clock-mode-style 12
    fi

    # set length
    tmux set-option -g status-left-length 100
    tmux set-option -g status-right-length 100

    # pane border styling
    if $show_border_contrast; then
        tmux set-option -g pane-active-border-style "fg=${blue}"
    else
        tmux set-option -g pane-active-border-style "fg=${light_purple}"
    fi
    tmux set-option -g pane-border-style "fg=${gray}"

    # message styling
    tmux set-option -g message-style "bg=${gray},fg=${blue}"

    # status bar
    tmux set-option -g status-style "bg=${gray},fg=${white}"

    # Status left
    if $show_powerline; then
        tmux set-option -g status-left "#[bg=${green},fg=${dark_gray}]#{?client_prefix,#[bg=${yellow}} ${left_icon} #[fg=${green},bg=${green}]#{?client_prefix,#[fg=${yellow}}${left_sep}"
        powerbg=${gray}
    else
        tmux set-option -g status-left "#[bg=${green},fg=${dark_gray}]#{?client_prefix,#[bg=${yellow}],} ${left_icon}"
    fi

    for lplugin in "${lplugins[@]}"; do

        if [ "$lplugin" = "git" ]; then
            IFS=' ' read -r -a colors <<<"$(get_tmux_option '@tmux2k-git-colors' 'green dark_gray')"
            script="#($current_dir/git.sh)"
            powerbg=${blue}
        fi

        if [ "$lplugin" = "battery" ]; then
            IFS=' ' read -r -a colors <<<"$(get_tmux_option '@tmux2k-battery-colors' 'pink dark_gray')"
            script="#($current_dir/battery.sh)"
        fi

        if [ "$lplugin" = "gpu-usage" ]; then
            IFS=' ' read -r -a colors <<<"$(get_tmux_option '@tmux2k-gpu-usage-colors' 'orange dark_gray')"
            script="#($current_dir/gpu_usage.sh)"
        fi

        if [ "$lplugin" = "cpu-usage" ]; then
            IFS=' ' read -r -a colors <<<"$(get_tmux_option '@tmux2k-cpu-usage-colors' 'blue dark_gray')"
            script="#($current_dir/cpu_info.sh)"
            powerbg=${yellow}
        fi

        if [ "$lplugin" = "ram-usage" ]; then
            IFS=' ' read -r -a colors <<<"$(get_tmux_option '@tmux2k-ram-usage-colors' 'yellow dark_gray')"
            script="#($current_dir/ram_info.sh)"
        fi

        if [ "$lplugin" = "network" ]; then
            IFS=' ' read -r -a colors <<<"$(get_tmux_option '@tmux2k-network-colors' 'purple dark_gray')"
            script="#($current_dir/network.sh)"
        fi

        if [ "$lplugin" = "network-bandwidth" ]; then
            IFS=' ' read -r -a colors <<<"$(get_tmux_option '@tmux2k-network-bandwidth-colors' 'purple dark_gray')"
            tmux set-option -g status-left 250
            script="#($current_dir/network_bandwidth.sh)"
        fi

        if [ "$lplugin" = "network-ping" ]; then
            IFS=' ' read -r -a colors <<<"$(get_tmux_option '@tmux2k-network-ping-colors' 'purple dark_gray')"
            script="#($current_dir/network_ping.sh)"
        fi

        if [ "$lplugin" = "weather" ]; then
            # wait unit $datafile exists just to avoid errors
            # this should almost never need to wait unless something unexpected occurs
            while [ ! -f $datafile ]; do
                sleep 0.01
            done

            IFS=' ' read -r -a colors <<<"$(get_tmux_option '@tmux2k-weather-colors' 'orange dark_gray')"
            script="#(cat $datafile)"
        fi

        if [ "$lplugin" = "time" ]; then
            IFS=' ' read -r -a colors <<<"$(get_tmux_option '@tmux2k-time-colors' 'cyan dark_gray')"
            if $show_day_month && $show_military; then # military time and dd/mm
                script=" %a %d/%m %R ${timezone} "
            elif $show_military; then # only military time
                script=" %a %m/%d %R ${timezone}"
            elif $show_day_month; then # only dd/mm
                script=" %a %d/%m %I:%M %p ${timezone} "
            else
                script=" %a %m/%d %I:%M %p ${timezone} "
            fi
        fi

        if $show_powerline; then
            tmux set-option -ga status-left "#[fg=${!colors[1]},bg=${!colors[0]}] $script #[fg=${!colors[0]},bg=${powerbg},nobold,nounderscore,noitalics]${left_sep}"
            powerbg=${gray}
            # powerbg=${!colors[0]}
        else
            tmux set-option -ga status-left "#[fg=${!colors[1]},bg=${!colors[0]}] $script "
        fi
    done

    # Status middle
    left_win_sep=""
    right_win_sep=""
    # Set window list at centre
    tmux set -g status-justify centre

    # Window option
    if $show_powerline; then
        tmux set-window-option -g window-status-current-format "#[fg=${blue},bg=${gray}]${left_win_sep}#[bg=${blue}]${current_flags}#[fg=${black}] #I:#W #[fg=${blue},bg=${gray}]${right_win_sep}"
    else
        tmux set-window-option -g window-status-current-format "#[fg=${white},bg=${blue}] #I:#W ${current_flags} "
    fi

    if $show_powerline; then
        tmux set-window-option -g window-status-format "#[fg=${light_gray},bg=${gray}]${left_win_sep}#[bg=${light_gray}]${flags}#[fg=${white}] #I:#W #[fg=${light_gray},bg=${gray}]${right_win_sep}"
    else
        tmux set-window-option -g window-status-format "#[fg=${white},bg=${light_gray}] #I:#W ${flags} "
    fi

    tmux set-window-option -g window-status-activity-style "bold"
    tmux set-window-option -g window-status-bell-style "bold"
    tmux set-window-option -g window-status-current-style "bold"

    # Status right
    tmux set-option -g status-right ""

    for rplugin in "${rplugins[@]}"; do

        if [ "$rplugin" = "git" ]; then
            IFS=' ' read -r -a colors <<<"$(get_tmux_option '@tmux2k-git-colors' 'green dark_gray')"
            script="#($current_dir/git.sh)"
        fi

        if [ "$rplugin" = "battery" ]; then
            IFS=' ' read -r -a colors <<<"$(get_tmux_option '@tmux2k-battery-colors' 'pink dark_gray')"
            script="#($current_dir/battery.sh)"
        fi

        if [ "$rplugin" = "gpu-usage" ]; then
            IFS=' ' read -r -a colors <<<"$(get_tmux_option '@tmux2k-gpu-usage-colors' 'orange dark_gray')"
            script="#($current_dir/gpu_usage.sh)"
        fi

        if [ "$rplugin" = "cpu-usage" ]; then
            IFS=' ' read -r -a colors <<<"$(get_tmux_option '@tmux2k-cpu-usage-colors' 'blue dark_gray')"
            script="#($current_dir/cpu_info.sh)"
        fi

        if [ "$rplugin" = "ram-usage" ]; then
            IFS=' ' read -r -a colors <<<"$(get_tmux_option '@tmux2k-ram-usage-colors' 'yellow dark_gray')"
            script="#($current_dir/ram_info.sh)"
        fi

        if [ "$rplugin" = "network" ]; then
            IFS=' ' read -r -a colors <<<"$(get_tmux_option '@tmux2k-network-colors' 'purple dark_gray')"
            script="#($current_dir/network.sh)"
        fi

        if [ "$rplugin" = "network-bandwidth" ]; then
            IFS=' ' read -r -a colors <<<"$(get_tmux_option '@tmux2k-network-bandwidth-colors' 'purple dark_gray')"
            tmux set-option -g status-right-length 250
            script="#($current_dir/network_bandwidth.sh)"
        fi

        if [ "$rplugin" = "network-ping" ]; then
            IFS=' ' read -r -a colors <<<"$(get_tmux_option '@tmux2k-network-ping-colors' 'purple dark_gray')"
            script="#($current_dir/network_ping.sh)"
        fi

        if [ "$rplugin" = "weather" ]; then
            # wait unit $datafile exists just to avoid errors
            # this should almost never need to wait unless something unexpected occurs
            while [ ! -f $datafile ]; do
                sleep 0.01
            done

            IFS=' ' read -r -a colors <<<"$(get_tmux_option '@tmux2k-weather-colors' 'orange dark_gray')"
            script="#(cat $datafile)"
        fi

        if [ "$rplugin" = "time" ]; then
            IFS=' ' read -r -a colors <<<"$(get_tmux_option '@tmux2k-time-colors' 'cyan dark_gray')"
            if $show_day_month && $show_military; then # military time and dd/mm
                script=" %a %d/%m %R ${timezone} "
            elif $show_military; then # only military time
                script=" %a %m/%d %R ${timezone}"
            elif $show_day_month; then # only dd/mm
                script=" %a %d/%m %I:%M %p ${timezone} "
            else
                script=" %a %m/%d %I:%M %p ${timezone} "
            fi

        fi

        if $show_powerline; then
            tmux set-option -ga status-right "#[fg=${!colors[0]},bg=${powerbg},nobold,nounderscore,noitalics]${right_sep}#[fg=${!colors[1]},bg=${!colors[0]}] $script "
            powerbg=${!colors[0]}
        else
            tmux set-option -ga status-right "#[fg=${!colors[1]},bg=${!colors[0]}] $script "
        fi
    done
}

# run main function
main
