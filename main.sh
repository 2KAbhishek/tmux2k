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
gray=$(get_tmux_option "@tmux2k-dark-gray" '#3f3f4f')
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
    ["bandwidth"]="purple text"
    ["battery"]="pink text"
    ["cpu"]="light_green text"
    ["cpu-temp"]="light_purple text"
    ["cwd"]="blue text"
    ["git"]="green text"
    ["gpu"]="red text"
    ["group"]="light_green text"
    ["network"]="purple text"
    ["ping"]="purple text"
    ["pomodoro"]="red text"
    ["ram"]="yellow text"
    ["session"]="green text"
    ["time"]="light_blue text"
    ["uptime"]="light_blue text"
    ["weather"]="orange text"
    ["window-list"]="black blue"
    ["tdo"]="green text"
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
        light_blue=$(get_tmux_option "@tmux2k-light-blue" '#91d7e3')
        blue=$(get_tmux_option "@tmux2k-blue" '#8aadf4')
        dark_blue=$(get_tmux_option "@tmux2k-dark-blue" '#00008b')
        light_green=$(get_tmux_option "@tmux2k-light-green" '#8bd5ca')
        green=$(get_tmux_option "@tmux2k-green" '#a6da95')
        dark_green=$(get_tmux_option "@tmux2k-dark-green" '#006400')
        light_orange=$(get_tmux_option "@tmux2k-light-orange" '#ffa07a')
        orange=$(get_tmux_option "@tmux2k-yellow" '#f5a97f')
        dark_orange=$(get_tmux_option "@tmux2k-dark-orange" '#ff4500')
        light_pink=$(get_tmux_option "@tmux2k-light-pink" '#ffb6c1')
        pink=$(get_tmux_option "@tmux2k-light-purple" '#f5bde6')
        dark_pink=$(get_tmux_option "@tmux2k-dark-pink" '#ff1493')
        light_purple=$(get_tmux_option "@tmux2k-light-purple" '#dda0dd')
        purple=$(get_tmux_option "@tmux2k-purple" '#b6a0fe')
        dark_purple=$(get_tmux_option "@tmux2k-dark-purple" '#4b0082')
        light_red=$(get_tmux_option "@tmux2k-light-red" '#ee99a0')
        red=$(get_tmux_option "@tmux2k-red" '#ed8796')
        dark_red=$(get_tmux_option "@tmux2k-dark-red" '#b03060')
        light_yellow=$(get_tmux_option "@tmux2k-light-yellow" '#fffacd')
        yellow=$(get_tmux_option "@tmux2k-light-yellow" '#eed49f')
        dark_yellow=$(get_tmux_option "@tmux2k-dark-yellow" '#b8860b')
        ;;
    "gruvbox")
        black=$(get_tmux_option "@tmux2k-black" '#282828')
        gray=$(get_tmux_option "@tmux2k-gray" '#4f4f4f')
        white=$(get_tmux_option "@tmux2k-white" '#ebdbb2')
        light_blue=$(get_tmux_option "@tmux2k-light-blue" '#83a598')
        blue=$(get_tmux_option "@tmux2k-blue" '#458588')
        dark_blue=$(get_tmux_option "@tmux2k-dark-blue" '#076678')
        light_green=$(get_tmux_option "@tmux2k-light-green" '#b8bb26')
        green=$(get_tmux_option "@tmux2k-green" '#98971a')
        dark_green=$(get_tmux_option "@tmux2k-dark-green" '#79740e')
        light_orange=$(get_tmux_option "@tmux2k-light-orange" '#ffa07a')
        orange=$(get_tmux_option "@tmux2k-yellow" '#d79921')
        dark_orange=$(get_tmux_option "@tmux2k-dark-orange" '#ff4500')
        light_pink=$(get_tmux_option "@tmux2k-light-pink" '#ffb6c1')
        pink=$(get_tmux_option "@tmux2k-light-purple" '#f386cb')
        dark_pink=$(get_tmux_option "@tmux2k-dark-pink" '#ff1493')
        light_purple=$(get_tmux_option "@tmux2k-light-purple" '#f386cb')
        purple=$(get_tmux_option "@tmux2k-purple" '#b162d6')
        dark_purple=$(get_tmux_option "@tmux2k-dark-purple" '#8f3f71')
        light_red=$(get_tmux_option "@tmux2k-light-red" '#fb4934')
        red=$(get_tmux_option "@tmux2k-red" '#cc241d')
        dark_red=$(get_tmux_option "@tmux2k-dark-red" '#9d0006')
        light_yellow=$(get_tmux_option "@tmux2k-light-yellow" '#fffacd')
        yellow=$(get_tmux_option "@tmux2k-light-yellow" '#fabd2f')
        dark_yellow=$(get_tmux_option "@tmux2k-dark-yellow" '#b8860b')
        ;;
    "monokai")
        black=$(get_tmux_option "@tmux2k-black" '#272822')
        gray=$(get_tmux_option "@tmux2k-gray" '#4f4f4f')
        white=$(get_tmux_option "@tmux2k-white" '#f8f8f2')
        light_blue=$(get_tmux_option "@tmux2k-light-blue" '#66d9ef')
        blue=$(get_tmux_option "@tmux2k-blue" '#66d9ef')
        dark_blue=$(get_tmux_option "@tmux2k-dark-blue" '#005f87')
        light_green=$(get_tmux_option "@tmux2k-light-green" '#a6e22e')
        green=$(get_tmux_option "@tmux2k-green" '#a6e22e')
        dark_green=$(get_tmux_option "@tmux2k-dark-green" '#5f8700')
        light_orange=$(get_tmux_option "@tmux2k-light-orange" '#ffa07a')
        orange=$(get_tmux_option "@tmux2k-yellow" '#ffa07a')
        dark_orange=$(get_tmux_option "@tmux2k-dark-orange" '#ff4500')
        light_pink=$(get_tmux_option "@tmux2k-light-pink" '#ffb6c1')
        pink=$(get_tmux_option "@tmux2k-light-purple" '#fe81ff')
        dark_pink=$(get_tmux_option "@tmux2k-dark-pink" '#ff1493')
        light_purple=$(get_tmux_option "@tmux2k-light-purple" '#fe81ff')
        purple=$(get_tmux_option "@tmux2k-purple" '#ae81ff')
        dark_purple=$(get_tmux_option "@tmux2k-dark-purple" '#5f00af')
        light_red=$(get_tmux_option "@tmux2k-light-red" '#ff6188')
        red=$(get_tmux_option "@tmux2k-red" '#f92672')
        dark_red=$(get_tmux_option "@tmux2k-dark-red" '#d7005f')
        light_yellow=$(get_tmux_option "@tmux2k-light-yellow" '#fffacd')
        yellow=$(get_tmux_option "@tmux2k-light-yellow" '#e6db74')
        dark_yellow=$(get_tmux_option "@tmux2k-dark-yellow" '#b8860b')
        ;;
    "onedark")
        black=$(get_tmux_option "@tmux2k-black" '#2d3139')
        gray=$(get_tmux_option "@tmux2k-gray" '#4f4f4f')
        white=$(get_tmux_option "@tmux2k-white" '#f8f8f8')
        light_blue=$(get_tmux_option "@tmux2k-light-blue" '#61afef')
        blue=$(get_tmux_option "@tmux2k-blue" '#61afef')
        dark_blue=$(get_tmux_option "@tmux2k-dark-blue" '#1b4f9c')
        light_green=$(get_tmux_option "@tmux2k-light-green" '#98c379')
        green=$(get_tmux_option "@tmux2k-green" '#98c379')
        dark_green=$(get_tmux_option "@tmux2k-dark-green" '#4b5632')
        light_orange=$(get_tmux_option "@tmux2k-light-orange" '#ffa07a')
        orange=$(get_tmux_option "@tmux2k-yellow" '#ffa07a')
        dark_orange=$(get_tmux_option "@tmux2k-dark-orange" '#ff4500')
        light_pink=$(get_tmux_option "@tmux2k-light-pink" '#ffb6c1')
        pink=$(get_tmux_option "@tmux2k-light-purple" '#f678cd')
        dark_pink=$(get_tmux_option "@tmux2k-dark-pink" '#ff1493')
        light_purple=$(get_tmux_option "@tmux2k-light-purple" '#f678cd')
        purple=$(get_tmux_option "@tmux2k-purple" '#c678fd')
        dark_purple=$(get_tmux_option "@tmux2k-dark-purple" '#5f00af')
        light_red=$(get_tmux_option "@tmux2k-light-red" '#e06c75')
        red=$(get_tmux_option "@tmux2k-red" '#e06c75')
        dark_red=$(get_tmux_option "@tmux2k-dark-red" '#be5046')
        light_yellow=$(get_tmux_option "@tmux2k-light-yellow" '#fffacd')
        yellow=$(get_tmux_option "@tmux2k-light-yellow" '#e5c07b')
        dark_yellow=$(get_tmux_option "@tmux2k-dark-yellow" '#b8860b')
        ;;
    "duo")
        duo_bg=$(get_tmux_option "@tmux2k-duo-bg" '#000000')
        duo_fg=$(get_tmux_option "@tmux2k-duo-fg" '#ffffff')
        black=$(get_tmux_option "@tmux2k-black" "$duo_bg")
        gray=$(get_tmux_option "@tmux2k-dark-gray" "$duo_bg")
        white=$(get_tmux_option "@tmux2k-white" "$duo_fg")
        light_blue=$(get_tmux_option "@tmux2k-light-blue" "$duo_fg")
        blue=$(get_tmux_option "@tmux2k-blue" "$duo_fg")
        dark_blue=$(get_tmux_option "@tmux2k-dark-blue" "$duo_fg")
        light_green=$(get_tmux_option "@tmux2k-light-green" "$duo_fg")
        green=$(get_tmux_option "@tmux2k-green" "$duo_fg")
        dark_green=$(get_tmux_option "@tmux2k-dark-green" "$duo_fg")
        light_orange=$(get_tmux_option "@tmux2k-light-orange" "$duo_fg")
        orange=$(get_tmux_option "@tmux2k-yellow" "$duo_fg")
        dark_orange=$(get_tmux_option "@tmux2k-dark-orange" "$duo_fg")
        light_pink=$(get_tmux_option "@tmux2k-light-pink" "$duo_fg")
        pink=$(get_tmux_option "@tmux2k-light-purple" "$duo_fg")
        dark_pink=$(get_tmux_option "@tmux2k-dark-pink" "$duo_fg")
        light_purple=$(get_tmux_option "@tmux2k-light-purple" "$duo_fg")
        purple=$(get_tmux_option "@tmux2k-purple" "$duo_fg")
        dark_purple=$(get_tmux_option "@tmux2k-dark-purple" "$duo_fg")
        light_red=$(get_tmux_option "@tmux2k-light-red" "$duo_fg")
        red=$(get_tmux_option "@tmux2k-red" "$duo_fg")
        dark_red=$(get_tmux_option "@tmux2k-dark-red" "$duo_fg")
        light_yellow=$(get_tmux_option "@tmux2k-light-yellow" "$duo_fg")
        yellow=$(get_tmux_option "@tmux2k-light-yellow" "$duo_fg")
        dark_yellow=$(get_tmux_option "@tmux2k-dark-yellow" "$duo_fg")
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
    message_bg=$(get_tmux_option "@tmux2k-message-bg" "$blue")
    message_fg=$(get_tmux_option "@tmux2k-message-fg" "$black")
    pane_active_border=$(get_tmux_option "@tmux2k-pane-active-border" "$blue")
    pane_border=$(get_tmux_option "@tmux2k-pane-border" "$gray")
    prefix_highlight=$(get_tmux_option "@tmux2k-prefix-highlight" "$blue")
}

set_options() {
    tmux set-option -g status-interval "$refresh_rate"
    tmux set-option -g status-left-length 100
    tmux set-option -g status-right-length 100
    tmux set-option -g status-left ""
    tmux set-option -g status-right ""

    tmux set-option -g status-style "bg=${bg_main},fg=${text}"
    tmux set-option -g message-style "bg=${message_bg},fg=${message_fg}"
    tmux set-option -g pane-active-border-style "bg=${bg_main},fg=${pane_active_border},bold"
    tmux set-option -g pane-border-style "fg=${pane_border}"

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
                        "#[fg=${!colors[1]},bg=${!colors[0]}]#{?client_prefix,#[bg=${prefix_highlight}],} $script #[fg=${!colors[0]},bg=${pl_bg}]#{?client_prefix,#[fg=${prefix_highlight}],}${l_sep}"
                else
                    tmux set-option -ga status-left \
                        "#[fg=${!colors[1]},bg=${!colors[0]}] $script #[fg=${!colors[0]},bg=${pl_bg}]${l_sep}"
                fi
                pl_bg=${bg_main}
            else
                if [ "$plugin" == "session" ]; then
                    tmux set-option -ga status-left "#[fg=${!colors[1]},bg=${!colors[0]}]#{?client_prefix,#[bg=${prefix_highlight}],} $script "
                else
                    tmux set-option -ga status-left "#[fg=${!colors[1]},bg=${!colors[0]}] $script "
                fi
            fi
        else
            if $show_powerline; then
                if [ "$plugin" == "session" ]; then
                    tmux set-option -ga status-right \
                        "#[fg=${!colors[0]},bg=${pl_bg}]#{?client_prefix,#[fg=${prefix_highlight}],}${r_sep}#[fg=${!colors[1]},bg=${!colors[0]}]#{?client_prefix,#[bg=${prefix_highlight}],} $script "
                else
                    tmux set-option -ga status-right \
                        "#[fg=${!colors[0]},bg=${pl_bg}]${r_sep}#[fg=${!colors[1]},bg=${!colors[0]}] $script "
                fi
                pl_bg=${!colors[0]}
            else
                if [ "$plugin" == "session" ]; then
                    tmux set-option -ga status-right "#[fg=${!colors[1]},bg=${!colors[0]}]#{?client_prefix,#[bg=${prefix_highlight}],} $script "
                else
                    tmux set-option -ga status-right "#[fg=${!colors[1]},bg=${!colors[0]}] $script "
                fi
            fi
        fi
    done
}

window_list() {
    IFS=' ' read -r -a colors <<<"$(get_plugin_colors "window-list")"
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
