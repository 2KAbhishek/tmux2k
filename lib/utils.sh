#!/usr/bin/env bash

# Global OS detection (0 subshell forks via OSTYPE with uname fallback)
case "${OSTYPE:-$(uname -s)}" in
darwin* | Darwin* | *darwin*) HOST_OS="darwin" ;;
linux* | Linux* | *linux*) HOST_OS="linux" ;;
freebsd* | FreeBSD* | *freebsd*) HOST_OS="freebsd" ;;
*) HOST_OS="linux" ;;
esac

utils_dir="${BASH_SOURCE[0]%/*}"
[ "$utils_dir" = "${BASH_SOURCE[0]}" ] && utils_dir="."

# Non-blocking caching wrapper
source "$utils_dir/cache_handler.sh"

declare -g -A TMUX2K_OPTIONS
if [ "${#TMUX2K_OPTIONS[@]}" -eq 0 ]; then
    while IFS=' ' read -r opt val; do
        TMUX2K_OPTIONS["$opt"]="$val"
    done < <(tmux show-options -g 2>/dev/null | grep "^@tmux2k-")
fi

get_tmux_option() {
    local option="$1"
    local default_value="$2"
    local val="${TMUX2K_OPTIONS[$option]}"

    if [ -z "$val" ]; then
        val="$(tmux show-option -gqv "$option" 2>/dev/null)"
    fi

    if [ -n "$val" ]; then
        val="${val#\"}"
        val="${val%\"}"
        val="${val#\'}"
        val="${val%\'}"
        if [[ "$val" =~ ^\$[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
            local var_name="${val#\$}"
            val="${!var_name}"
        elif [[ "$val" == *"\$HOME"* ]]; then
            val="${val//\$HOME/$HOME}"
        elif [[ "$val" == "~"* ]]; then
            val="${val/#\~/$HOME}"
        fi
        printf '%s\n' "$val"
    else
        printf '%s\n' "$default_value"
    fi
}

normalize_padding() {
    percent_len=${#1}
    max_len=${2:-4}
    diff_len=$((max_len - percent_len))
    # if the diff_len is even, left will have 1 more space than right
    left_spaces=$(((diff_len + 1) / 2))
    right_spaces=$((diff_len / 2))
    printf "%${left_spaces}s%s%${right_spaces}s\n" "" "$1" ""
}

get_pane_dir() {
    tmux display-message -p -F "#{pane_current_path}" 2>/dev/null
}

get_desktop_environment() {
    case "$HOST_OS" in
    darwin)
        echo "darwin"
        ;;
    linux)
        local de="${XDG_CURRENT_DESKTOP:-$DESKTOP_SESSION}"
        local de_lower="${de,,}"
        if [ -n "$SWAYSOCK" ] || [[ "$de_lower" == *"sway"* ]]; then
            echo "sway"
        elif [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ] || [[ "$de_lower" == *"hyprland"* ]]; then
            echo "hyprland"
        else
            case "$de_lower" in
            *kde* | *plasma*) echo "kde" ;;
            *gnome* | *ubuntu* | *pop*) echo "gnome" ;;
            *xfce*) echo "xfce" ;;
            *cinnamon*) echo "cinnamon" ;;
            *mate*) echo "mate" ;;
            *)
                if [ -n "$DISPLAY" ]; then
                    echo "x11"
                else
                    echo "linux"
                fi
                ;;
            esac
        fi
        ;;
    esac
}

exec_first_available() {
    local cmd
    for cmd in "$@"; do
        local bin="${cmd%% *}"
        if command -v "$bin" >/dev/null 2>&1; then
            eval "$cmd"
            return $?
        fi
    done
    return 1
}
