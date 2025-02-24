#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir/lib/utils.sh"

refresh_rate=$(get_tmux_option "@tmux2k-refresh-rate" 60)
show_powerline=$(get_tmux_option "@tmux2k-show-powerline" true)
l_sep=$(get_tmux_option "@tmux2k-left-sep" )
r_sep=$(get_tmux_option "@tmux2k-right-sep" )
wl_sep=$(get_tmux_option "@tmux2k-window-list-left-sep" )
wr_sep=$(get_tmux_option "@tmux2k-window-list-right-sep" )
window_list_alignment=$(get_tmux_option "@tmux2k-window-list-alignment" 'absolute-centre')
window_list_format=$(get_tmux_option "@tmux2k-window-list-format" '#I:#W')
window_list_flags=$(get_tmux_option "@tmux2k-window-list-flags" true)
window_list_compact=$(get_tmux_option "@tmux2k-window-list-compact" false)
IFS=' ' read -r -a lplugins <<<"$(get_tmux_option '@tmux2k-left-plugins' 'session git cwd')"
IFS=' ' read -r -a rplugins <<<"$(get_tmux_option '@tmux2k-right-plugins' 'cpu ram battery network time')"
theme=$(get_tmux_option "@tmux2k-theme" 'default')
icons_only=$(get_tmux_option "@tmux2k-icons-only" false)

white=$(get_tmux_option "@tmux2k-white" '#ffffff')
gray=$(get_tmux_option "@tmux2k-dark-gray" '#2f2f2f')
black=$(get_tmux_option "@tmux2k-black" '#000000')

light_blue=$(get_tmux_option "@tmux2k-light-blue" '#11dddd')
blue=$(get_tmux_option "@tmux2k-blue" '#1688f0')
dark_blue=$(get_tmux_option "@tmux2k-dark-blue" '#0000CD')

light_green=$(get_tmux_option "@tmux2k-light-green" '#ccffcc')
green=$(get_tmux_option "@tmux2k-green" '#3dd50a')
dark_green=$(get_tmux_option "@tmux2k-dark-green" '#006400')

light_orange=$(get_tmux_option "@tmux2k-light-orange" '#FFA07a')
orange=$(get_tmux_option "@tmux2k-orange" '#FFA500')
dark_orange=$(get_tmux_option "@tmux2k-dark-orange" '#FF4500')

light_pink=$(get_tmux_option "@tmux2k-light-pink" '#FFB6C1')
pink=$(get_tmux_option "@tmux2k-pink" '#FF69B4')
dark_pink=$(get_tmux_option "@tmux2k-dark-pink" '#FF1493')

light_purple=$(get_tmux_option "@tmux2k-light-purple" '#DDA0DD')
purple=$(get_tmux_option "@tmux2k-purple" '#bf58ff')
dark_purple=$(get_tmux_option "@tmux2k-dark-purple" '#4b0082')

light_red=$(get_tmux_option "@tmux2k-light-red" '#E68a8a')
red=$(get_tmux_option "@tmux2k-red" '#ff1f1f')
dark_red=$(get_tmux_option "@tmux2k-dark-red" '#800000')

light_yellow=$(get_tmux_option "@tmux2k-light-yellow" '#fffacd')
yellow=$(get_tmux_option "@tmux2k-yellow" '#ffd21a')
dark_yellow=$(get_tmux_option "@tmux2k-dark-yellow" '#b8860b')

declare -A plugin_colors=(
    ["session"]="green text"
    ["git"]="green text"
    ["cpu"]="light_green text"
    ["cwd"]="blue text"
    ["ram"]="yellow text"
    ["gpu"]="red text"
    ["battery"]="pink text"
    ["network"]="purple text"
    ["bandwidth"]="purple text"
    ["ping"]="purple text"
    ["weather"]="orange text"
    ["time"]="light_blue text"
    ["pomodoro"]="red text"
    ["window_list"]="black blue"
    ["custom"]="red text"
)

reverse_colors() {
    local colors=($1)
    echo "${colors[1]} ${colors[0]}"
}

get_plugin_colors() {
    local plugin_name="$1"
    local default_colors="${plugin_colors[$plugin_name]}"
    get_tmux_option "@tmux2k-${plugin_name}-colors" "$default_colors"
}

get_plugin_bg() {
    IFS=' ' read -r -a colors <<<"$(get_plugin_colors "$1")"
    return "${colors[0]}"
}

set_theme() {
    case $theme in
    "catppuccin")
        black=$(get_tmux_option "@tmux2k-black" '#1e2030')
        gray=$(get_tmux_option "@tmux2k-gray" '#3f3f3f')
        white=$(get_tmux_option "@tmux2k-white" '#ffffff')
        red=$(get_tmux_option "@tmux2k-red" '#ed8796')
        light_red=$(get_tmux_option "@tmux2k-light-red" '#ee99a0')
        green=$(get_tmux_option "@tmux2k-green" '#a6da95')
        light_green=$(get_tmux_option "@tmux2k-light-green" '#8bd5ca')
        blue=$(get_tmux_option "@tmux2k-blue" '#8aadf4')
        light_blue=$(get_tmux_option "@tmux2k-light-blue" '#91d7e3')
        yellow=$(get_tmux_option "@tmux2k-light-yellow" '#eed49f')
        orange=$(get_tmux_option "@tmux2k-yellow" '#f5a97f')
        purple=$(get_tmux_option "@tmux2k-purple" '#b6a0fe')
        pink=$(get_tmux_option "@tmux2k-light-purple" '#f5bde6')
        ;;
    "gruvbox")
        black=$(get_tmux_option "@tmux2k-black" '#282828')
        gray=$(get_tmux_option "@tmux2k-gray" '#4f4f4f')
        white=$(get_tmux_option "@tmux2k-white" '#ebdbb2')
        red=$(get_tmux_option "@tmux2k-red" '#cc241d')
        light_red=$(get_tmux_option "@tmux2k-light-red" '#fb4934')
        green=$(get_tmux_option "@tmux2k-green" '#98971a')
        light_green=$(get_tmux_option "@tmux2k-light-green" '#b8bb26')
        blue=$(get_tmux_option "@tmux2k-blue" '#458588')
        light_blue=$(get_tmux_option "@tmux2k-light-blue" '#83a598')
        orange=$(get_tmux_option "@tmux2k-yellow" '#d79921')
        yellow=$(get_tmux_option "@tmux2k-light-yellow" '#fabd2f')
        purple=$(get_tmux_option "@tmux2k-purple" '#b162d6')
        pink=$(get_tmux_option "@tmux2k-light-purple" '#f386cb')
        ;;
    "monokai")
        black=$(get_tmux_option "@tmux2k-black" '#272822')
        gray=$(get_tmux_option "@tmux2k-gray" '#4f4f4f')
        white=$(get_tmux_option "@tmux2k-white" '#f8f8f2')
        red=$(get_tmux_option "@tmux2k-red" '#f92672')
        light_red=$(get_tmux_option "@tmux2k-light-red" '#ff6188')
        green=$(get_tmux_option "@tmux2k-green" '#a6e22e')
        light_green=$(get_tmux_option "@tmux2k-light-green" '#a6e22e')
        blue=$(get_tmux_option "@tmux2k-blue" '#66d9ef')
        light_blue=$(get_tmux_option "@tmux2k-light-blue" '#66d9ef')
        orange=$(get_tmux_option "@tmux2k-yellow" '#ffa07a')
        yellow=$(get_tmux_option "@tmux2k-light-yellow" '#e6db74')
        purple=$(get_tmux_option "@tmux2k-purple" '#ae81ff')
        pink=$(get_tmux_option "@tmux2k-light-purple" '#fe81ff')
        ;;
    "onedark")
        black=$(get_tmux_option "@tmux2k-black" '#2d3139')
        gray=$(get_tmux_option "@tmux2k-gray" '#4f4f4f')
        white=$(get_tmux_option "@tmux2k-white" '#f8f8f8')
        red=$(get_tmux_option "@tmux2k-red" '#e06c75')
        light_red=$(get_tmux_option "@tmux2k-light-red" '#e06c75')
        green=$(get_tmux_option "@tmux2k-green" '#98c379')
        light_green=$(get_tmux_option "@tmux2k-light-green" '#98c379')
        blue=$(get_tmux_option "@tmux2k-blue" '#61afef')
        light_blue=$(get_tmux_option "@tmux2k-light-blue" '#61afef')
        orange=$(get_tmux_option "@tmux2k-yellow" '#ffa07a')
        yellow=$(get_tmux_option "@tmux2k-light-yellow" '#e5c07b')
        purple=$(get_tmux_option "@tmux2k-purple" '#c678fd')
        pink=$(get_tmux_option "@tmux2k-light-purple" '#f678cd')
        ;;
    "duo")
        duo_bg=$(get_tmux_option "@tmux2k-duo-bg" '#000000')
        duo_fg=$(get_tmux_option "@tmux2k-duo-fg" '#ffffff')
        black=$(get_tmux_option "@tmux2k-black" "$duo_bg")
        gray=$(get_tmux_option "@tmux2k-dark-gray" "$duo_bg")
        white=$(get_tmux_option "@tmux2k-white" "$duo_fg")
        red=$(get_tmux_option "@tmux2k-red" "$duo_fg")
        light_red=$(get_tmux_option "@tmux2k-light-red" "$duo_fg")
        green=$(get_tmux_option "@tmux2k-green" "$duo_fg")
        light_green=$(get_tmux_option "@tmux2k-light-green" "$duo_fg")
        blue=$(get_tmux_option "@tmux2k-blue" "$duo_fg")
        light_blue=$(get_tmux_option "@tmux2k-light-blue" "$duo_fg")
        yellow=$(get_tmux_option "@tmux2k-yellow" "$duo_fg")
        orange=$(get_tmux_option "@tmux2k-yellow" "$duo_fg")
        purple=$(get_tmux_option "@tmux2k-purple" "$duo_fg")
        pink=$(get_tmux_option "@tmux2k-light-purple" "$duo_fg")
        ;;
    esac

    if $icons_only; then
        show_powerline=false
        for plugin in "${!plugin_colors[@]}"; do
            plugin_colors[$plugin]=$(reverse_colors "${plugin_colors[$plugin]}")
        done
    fi

    text=$(get_tmux_option "@tmux2k-text" "$black")
    bg_main=$(get_tmux_option "@tmux2k-bg-main" "$black")
    bg_alt=$(get_tmux_option "@tmux2k-bg-alt" "$gray")
    highlight=$(get_tmux_option "@tmux2k-highlight" "$blue")
}

set_options() {
    tmux set-option -g status-interval "$refresh_rate"
    tmux set-option -g status-left-length 100
    tmux set-option -g status-right-length 100
    tmux set-option -g status-left ""
    tmux set-option -g status-right ""

    tmux set-option -g pane-active-border-style "fg=${highlight}"
    tmux set-option -g pane-border-style "fg=${bg_main}"
    tmux set-option -g message-style "bg=${bg_main},fg=${highlight}"
    tmux set-option -g status-style "bg=${bg_main},fg=${white}"
    tmux set -g status-justify "$window_list_alignment"

    tmux set-window-option -g window-status-activity-style "bold"
    tmux set-window-option -g window-status-bell-style "bold"
    tmux set-window-option -g window-status-current-style "bold"
}

status_bar() {
    side=$1
    if [ "$side" == "left" ]; then
        plugins=("${lplugins[@]}")
    else
        plugins=("${rplugins[@]}")
    fi

    for plugin_index in "${!plugins[@]}"; do
        plugin="${plugins[$plugin_index]}"
        IFS=' ' read -r -a colors <<<"$(get_plugin_colors "$plugin")"
        script="#($current_dir/plugins/$plugin.sh)"

        if [ "$side" == "left" ]; then
            if $show_powerline; then
                next_plugin=${plugins[$((plugin_index + 1))]}
                IFS=' ' read -r -a next_colors <<<"$(get_plugin_colors "$next_plugin")"
                pl_bg=${!next_colors[0]:-$bg_main}
                if [ "$plugin" == "session" ]; then
                    tmux set-option -ga status-left \
                        "#[fg=${!colors[1]},bg=${!colors[0]}]#{?client_prefix,#[bg=${highlight}],} $script #[fg=${!colors[0]},bg=${pl_bg},nobold,nounderscore,noitalics]${l_sep}"
                else
                    tmux set-option -ga status-left \
                        "#[fg=${!colors[1]},bg=${!colors[0]}] $script #[fg=${!colors[0]},bg=${pl_bg},nobold,nounderscore,noitalics]${l_sep}"
                fi
                pl_bg=${bg_main}
            else
                if [ "$plugin" == "session" ]; then
                    tmux set-option -ga status-left "#[fg=${!colors[1]},bg=${!colors[0]}]#{?client_prefix,#[bg=${highlight}],} $script "
                else
                    tmux set-option -ga status-left "#[fg=${!colors[1]},bg=${!colors[0]}] $script "
                fi
            fi
        else
            if $show_powerline; then
                if [ "$plugin" == "session" ]; then
                    tmux set-option -ga status-right \
                        "#[fg=${!colors[0]},bg=${pl_bg},nobold,nounderscore,noitalics]${r_sep}#[fg=${!colors[1]},bg=${!colors[0]}]#{?client_prefix,#[bg=${highlight}],} $script "
                else
                    tmux set-option -ga status-right \
                        "#[fg=${!colors[0]},bg=${pl_bg},nobold,nounderscore,noitalics]${r_sep}#[fg=${!colors[1]},bg=${!colors[0]}] $script "
                fi
                pl_bg=${!colors[0]}
            else
                if [ "$plugin" == "session" ]; then
                    tmux set-option -ga status-right "#[fg=${!colors[1]},bg=${!colors[0]}]#{?client_prefix,#[bg=${highlight}],} $script "
                else
                    tmux set-option -ga status-right "#[fg=${!colors[1]},bg=${!colors[0]}] $script "
                fi
            fi
        fi
    done
}

window_list() {
    IFS=' ' read -r -a colors <<<"$(get_plugin_colors "window_list")"
    wbg=${!colors[0]}
    wfg=${!colors[1]}

    spacer=" "
    if $window_list_compact; then
        spacer=""
    fi

    if $window_list_flags; then
        flags="#{?window_flags,#[fg=${red}]#{window_flags},}"
        current_flags="#{?window_flags,#[fg=${light_green}]#{window_flags},}"
    fi

    if $show_powerline; then
        tmux set-window-option -g window-status-current-format \
            "#[fg=${wfg},bg=${wbg}]${wl_sep}#[bg=${wfg}]${current_flags}#[fg=${wbg}]${spacer}${window_list_format}${spacer}#[fg=${wfg},bg=${wbg}]${wr_sep}"
        tmux set-window-option -g window-status-format \
            "#[fg=${bg_alt},bg=${wbg}]${wl_sep}#[bg=${bg_alt}]${flags}#[fg=${white}]${spacer}${window_list_format}${spacer}#[fg=${bg_alt},bg=${wbg}]${wr_sep}"
    else
        tmux set-window-option -g window-status-current-format "#[fg=${wbg},bg=${wfg}] ${window_list_format}${spacer}${current_flags} "
        tmux set-window-option -g window-status-format "#[fg=${white},bg=${bg_alt}] ${window_list_format}${spacer}${flags} "
    fi

    if $icons_only; then
        tmux set-window-option -g window-status-current-format "#[fg=${wbg},bg=${wfg}]${spacer}${window_list_format}${spacer}"
        tmux set-window-option -g window-status-format "#[fg=${white},bg=${wfg}]${spacer}${window_list_format}${spacer}"
    fi
}

main() {
    set_theme
    set_options
    status_bar "left"
    window_list
    status_bar "right"
}

main
