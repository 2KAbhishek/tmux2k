#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir"/utils.sh

show_powerline=$(get_tmux_option "@tmux2k-show-powerline" true)
window_list_alignment=$(get_tmux_option "@tmux2k-window-list-alignment" 'centre')
refresh_rate=$(get_tmux_option "@tmux2k-refresh-rate" 60)
start_icon=$(get_tmux_option "@tmux2k-start-icon" '')
l_sep=$(get_tmux_option "@tmux2k-left-sep" )
r_sep=$(get_tmux_option "@tmux2k-right-sep" )
wl_sep=$(get_tmux_option "@tmux2k-window-left-sep" )
wr_sep=$(get_tmux_option "@tmux2k-window-right-sep" )
show_flags=$(get_tmux_option "@tmux2k-show-flags" true)
IFS=' ' read -r -a lplugins <<<"$(get_tmux_option '@tmux2k-left-plugins' 'git cpu ram')"
IFS=' ' read -r -a rplugins <<<"$(get_tmux_option '@tmux2k-right-plugins' 'battery network time')"
theme=$(get_tmux_option "@tmux2k-theme" 'default')
icons_only=$(get_tmux_option "@tmux2k-icons-only" false)
compact=$(get_tmux_option "@tmux2k-compact-windows" false)

text=$(get_tmux_option "@tmux2k-text" '#282a36')
bg_main=$(get_tmux_option "@tmux2k-bg-main" '#000000')
bg_alt=$(get_tmux_option "@tmux2k-bg-alt" '#1f1f1f')
black=$(get_tmux_option "@tmux2k-black" '#0a0a0f')
white=$(get_tmux_option "@tmux2k-white" '#d5d5da')
red=$(get_tmux_option "@tmux2k-red" '#ff001f')
light_red=$(get_tmux_option "@tmux2k-light-red" '#ff0055')
green=$(get_tmux_option "@tmux2k-green" '#3dd50a')
light_green=$(get_tmux_option "@tmux2k-light-green" '#ccffcc')
blue=$(get_tmux_option "@tmux2k-blue" '#1688f0')
light_blue=$(get_tmux_option "@tmux2k-light-blue" '#11dddd')
yellow=$(get_tmux_option "@tmux2k-yellow" '#ffb86c')
light_yellow=$(get_tmux_option "@tmux2k-light-yellow" '#ffd21a')
purple=$(get_tmux_option "@tmux2k-purple" '#bf58ff')
light_purple=$(get_tmux_option "@tmux2k-light-purple" '#ff65c6')

declare -A plugin_colors=(
    ["git"]="green text"
    ["cpu"]="blue text"
    ["ram"]="light_yellow text"
    ["gpu"]="yellow text"
    ["battery"]="light_purple text"
    ["network"]="purple text"
    ["bandwidth"]="purple text"
    ["ping"]="purple text"
    ["weather"]="yellow text"
    ["time"]="light_blue text"
    ["window"]="bg_main blue"
)

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
        bg_main=$(get_tmux_option "@tmux2k-bg-main" '#24273a')
        bg_alt=$(get_tmux_option "@tmux2k-bg-alt" '#363a4f')
        black=$(get_tmux_option "@tmux2k-black" '#1e2030')
        white=$(get_tmux_option "@tmux2k-white" '#ffffff')
        red=$(get_tmux_option "@tmux2k-red" '#ed8796')
        light_red=$(get_tmux_option "@tmux2k-light-red" '#ee99a0')
        green=$(get_tmux_option "@tmux2k-green" '#a6da95')
        light_green=$(get_tmux_option "@tmux2k-light-green" '#8bd5ca')
        blue=$(get_tmux_option "@tmux2k-blue" '#8aadf4')
        light_blue=$(get_tmux_option "@tmux2k-light-blue" '#91d7e3')
        yellow=$(get_tmux_option "@tmux2k-yellow" '#f5a97f')
        light_yellow=$(get_tmux_option "@tmux2k-light-yellow" '#eed49f')
        purple=$(get_tmux_option "@tmux2k-purple" '#b6a0fe')
        light_purple=$(get_tmux_option "@tmux2k-light-purple" '#f5bde6')
        ;;
    "duo")
        duo_bg=$(get_tmux_option "@tmux2k-duo-bg" '#000000')
        duo_fg=$(get_tmux_option "@tmux2k-duo-fg" '#ffffff')
        text=$(get_tmux_option "@tmux2k-white" "$duo_bg")
        bg_main=$(get_tmux_option "@tmux2k-bg-main" "$duo_bg")
        bg_alt=$(get_tmux_option "@tmux2k-bg-alt" "$duo_bg")
        black=$(get_tmux_option "@tmux2k-black" "$duo_bg")
        white=$(get_tmux_option "@tmux2k-white" "$duo_fg")
        red=$(get_tmux_option "@tmux2k-red" "$duo_fg")
        light_red=$(get_tmux_option "@tmux2k-light-red" "$duo_fg")
        green=$(get_tmux_option "@tmux2k-green" "$duo_fg")
        light_green=$(get_tmux_option "@tmux2k-light-green" "$duo_fg")
        blue=$(get_tmux_option "@tmux2k-blue" "$duo_fg")
        light_blue=$(get_tmux_option "@tmux2k-light-blue" "$duo_fg")
        yellow=$(get_tmux_option "@tmux2k-yellow" "$duo_fg")
        light_yellow=$(get_tmux_option "@tmux2k-light-yellow" "$duo_fg")
        purple=$(get_tmux_option "@tmux2k-purple" "$duo_fg")
        light_purple=$(get_tmux_option "@tmux2k-light-purple" "$duo_fg")
        ;;
    "gruvbox")
        bg_main=$(get_tmux_option "@tmux2k-bg-main" '#282828')
        bg_alt=$(get_tmux_option "@tmux2k-bg-alt" '#3c3836')
        black=$(get_tmux_option "@tmux2k-black" '#282828')
        white=$(get_tmux_option "@tmux2k-white" '#ebdbb2')
        red=$(get_tmux_option "@tmux2k-red" '#cc241d')
        light_red=$(get_tmux_option "@tmux2k-light-red" '#fb4934')
        green=$(get_tmux_option "@tmux2k-green" '#98971a')
        light_green=$(get_tmux_option "@tmux2k-light-green" '#b8bb26')
        blue=$(get_tmux_option "@tmux2k-blue" '#458588')
        light_blue=$(get_tmux_option "@tmux2k-light-blue" '#83a598')
        yellow=$(get_tmux_option "@tmux2k-yellow" '#d79921')
        light_yellow=$(get_tmux_option "@tmux2k-light-yellow" '#fabd2f')
        purple=$(get_tmux_option "@tmux2k-purple" '#b162d6')
        light_purple=$(get_tmux_option "@tmux2k-light-purple" '#f386cb')
        ;;
    "monokai")
        bg_main=$(get_tmux_option "@tmux2k-bg-main" '#272822')
        bg_alt=$(get_tmux_option "@tmux2k-bg-alt" '#3e3d32')
        black=$(get_tmux_option "@tmux2k-black" '#272822')
        white=$(get_tmux_option "@tmux2k-white" '#f8f8f2')
        red=$(get_tmux_option "@tmux2k-red" '#f92672')
        light_red=$(get_tmux_option "@tmux2k-light-red" '#ff6188')
        green=$(get_tmux_option "@tmux2k-green" '#a6e22e')
        light_green=$(get_tmux_option "@tmux2k-light-green" '#a6e22e')
        blue=$(get_tmux_option "@tmux2k-blue" '#66d9ef')
        light_blue=$(get_tmux_option "@tmux2k-light-blue" '#66d9ef')
        yellow=$(get_tmux_option "@tmux2k-yellow" '#e6db74')
        light_yellow=$(get_tmux_option "@tmux2k-light-yellow" '#e6db74')
        purple=$(get_tmux_option "@tmux2k-purple" '#ae81ff')
        light_purple=$(get_tmux_option "@tmux2k-light-purple" '#fe81ff')
        ;;
    "onedark")
        bg_main=$(get_tmux_option "@tmux2k-bg-main" '#282c34')
        bg_alt=$(get_tmux_option "@tmux2k-bg-alt" '#353b45')
        black=$(get_tmux_option "@tmux2k-black" '#2d3139')
        white=$(get_tmux_option "@tmux2k-white" '#abb2bf')
        red=$(get_tmux_option "@tmux2k-red" '#e06c75')
        light_red=$(get_tmux_option "@tmux2k-light-red" '#e06c75')
        green=$(get_tmux_option "@tmux2k-green" '#98c379')
        light_green=$(get_tmux_option "@tmux2k-light-green" '#98c379')
        blue=$(get_tmux_option "@tmux2k-blue" '#61afef')
        light_blue=$(get_tmux_option "@tmux2k-light-blue" '#61afef')
        yellow=$(get_tmux_option "@tmux2k-yellow" '#e5c07b')
        light_yellow=$(get_tmux_option "@tmux2k-light-yellow" '#e5c07b')
        purple=$(get_tmux_option "@tmux2k-purple" '#c678fd')
        light_purple=$(get_tmux_option "@tmux2k-light-purple" '#f678cd')
        ;;
    esac

    if $icons_only; then
        show_powerline=false
        text=$bg_main
        plugin_colors=(
            ["git"]="text green"
            ["cpu"]="text blue"
            ["ram"]="text light_yellow"
            ["gpu"]="text yellow"
            ["battery"]="text light_purple"
            ["network"]="text purple"
            ["bandwidth"]="text purple"
            ["ping"]="text purple"
            ["weather"]="text yellow"
            ["time"]="text light_blue"
            ["window"]="blue bg_main"
        )
    fi
}

set_options() {
    tmux set-option -g status-interval "$refresh_rate"
    tmux set-option -g status-left-length 100
    tmux set-option -g status-right-length 100
    tmux set-option -g status-left ""
    tmux set-option -g status-right ""

    tmux set-option -g pane-active-border-style "fg=${blue}"
    tmux set-option -g pane-border-style "fg=${bg_main}"
    tmux set-option -g message-style "bg=${bg_main},fg=${blue}"
    tmux set-option -g status-style "bg=${bg_main},fg=${white}"
    tmux set -g status-justify "$window_list_alignment"

    tmux set-window-option -g window-status-activity-style "bold"
    tmux set-window-option -g window-status-bell-style "bold"
    tmux set-window-option -g window-status-current-style "bold"
}

start_icon() {
    case $start_icon in
    session) start_icon="#S" ;;
    window) start_icon="#W" ;;
    esac

    first_plugin=${lplugins[0]}
    IFS=' ' read -r -a first_colors <<<"$(get_plugin_colors "$first_plugin")"
    tmux set-option -g status-left "#[bg=${!first_colors[0]},fg=${!first_colors[1]}]#{?client_prefix,#[bg=${light_yellow},} ${start_icon} "
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
        if [ -z "${plugin_colors[$plugin]}" ]; then
            continue
        fi

        IFS=' ' read -r -a colors <<<"$(get_plugin_colors "$plugin")"
        script="#($current_dir/$plugin.sh)"

        if [ "$side" == "left" ]; then
            if $show_powerline; then
                next_plugin=${plugins[$((plugin_index + 1))]}
                IFS=' ' read -r -a next_colors <<<"$(get_plugin_colors "$next_plugin")"
                pl_bg=${!next_colors[0]:-$bg_main}
                tmux set-option -ga status-left \
                    "#[fg=${!colors[1]},bg=${!colors[0]}] $script #[fg=${!colors[0]},bg=${pl_bg},nobold,nounderscore,noitalics]${l_sep}"
                pl_bg=${bg_main}
            else
                tmux set-option -ga status-left "#[fg=${!colors[1]},bg=${!colors[0]}] $script "
            fi
        else
            if $show_powerline; then
                tmux set-option -ga status-right \
                    "#[fg=${!colors[0]},bg=${pl_bg},nobold,nounderscore,noitalics]${r_sep}#[fg=${!colors[1]},bg=${!colors[0]}] $script "
                pl_bg=${!colors[0]}
            else
                tmux set-option -ga status-right "#[fg=${!colors[1]},bg=${!colors[0]}] $script "
            fi
        fi
    done
}

window_list() {
    IFS=' ' read -r -a colors <<<"$(get_plugin_colors "window")"
    wbg=${!colors[0]}
    wfg=${!colors[1]}

    spacer=" "
    if $compact; then
        spacer=""
    fi

    if $show_flags; then
        flags="#{?window_flags,#[fg=${light_red}]#{window_flags},}"
        current_flags="#{?window_flags,#[fg=${light_green}]#{window_flags},}"
    fi

    if $show_powerline; then
        tmux set-window-option -g window-status-current-format \
            "#[fg=${wfg},bg=${wbg}]${wl_sep}#[bg=${wfg}]${current_flags}#[fg=${wbg}]${spacer}#I:#W${spacer}#[fg=${wfg},bg=${wbg}]${wr_sep}"
        tmux set-window-option -g window-status-format \
            "#[fg=${bg_alt},bg=${wbg}]${wl_sep}#[bg=${bg_alt}]${flags}#[fg=${white}]${spacer}#I:#W${spacer}#[fg=${bg_alt},bg=${wbg}]${wr_sep}"
    else
        tmux set-window-option -g window-status-current-format "#[fg=${wbg},bg=${wfg}] #I:#W${spacer}${current_flags} "
        tmux set-window-option -g window-status-format "#[fg=${white},bg=${bg_alt}] #I:#W${spacer}${flags} "
    fi

    if $icons_only; then
        tmux set-window-option -g window-status-current-format "#[fg=${wbg},bg=${wfg}]${spacer}#I:#W${spacer}"
        tmux set-window-option -g window-status-format "#[fg=${white},bg=${wfg}]${spacer}#I:#W${spacer}"
    fi
}

main() {
    set_theme
    set_options
    start_icon
    status_bar "left"
    window_list
    status_bar "right"
}

main
