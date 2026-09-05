#!/usr/bin/env bash

export PATH="$HOME/.local/bin:$HOME/bin:$PATH"
export LC_ALL=en_US.UTF-8

current_dir="${BASH_SOURCE[0]%/*}"
[ "$current_dir" = "${BASH_SOURCE[0]}" ] && current_dir="."
source "$current_dir/utils.sh"

bandwidth_popup() {
    exec_first_available "bmon" "nload" "iftop" "btop"
}

battery_popup() {
    exec_first_available "btop" "htop" "top"
}

cpu_popup() {
    exec_first_available "btop" "htop" "glances" "top"
}

cpu_temp_popup() {
    exec_first_available "watch -n 1 -c sensors" "s-tui"
}

cwd_popup() {
    exec_first_available "ranger" "yazi" "nnn" "lf" "mc"
}

docker_popup() {
    exec_first_available "lazydocker" "oxker" "docker ps; read -n 1"
}

git_popup() {
    exec_first_available "lazygit" "gitui" "tig" "git status; read -n 1"
}

github_popup() {
    exec_first_available "gh dash" "gh pr list"
}

gpu_popup() {
    exec_first_available "nvtop" "radeontop" "nvidia-smi; read -n 1"
}

keyboard_layout_popup() {
    case "$(get_desktop_environment)" in
    sway | hyprland) exec_first_available "wcm" "gnome-control-center keyboard" "kcmshell6 kcm_keyboard" ;;
    gnome) exec_first_available "gnome-control-center keyboard" ;;
    kde) exec_first_available "kcmshell6 kcm_keyboard" "kcmshell5 kcm_keyboard" ;;
    xfce) exec_first_available "xfce4-keyboard-settings" ;;
    cinnamon) exec_first_available "cinnamon-settings keyboard" ;;
    mate) exec_first_available "mate-keyboard-properties" ;;
    x11) exec_first_available "xfce4-keyboard-settings" "gnome-control-center keyboard" "kcmshell6 kcm_keyboard" ;;
    darwin) open 'x-apple.systempreferences:com.apple.preference.keyboard' ;;
    esac
}

network_popup() {
    exec_first_available "nmtui" "impala"
}

ping_popup() {
    exec_first_available "gping google.com" "ping google.com"
}

ram_popup() {
    exec_first_available "htop" "btop" "top"
}

storage_popup() {
    exec_first_available "ncdu --color dark ~" "gdu ~" "df -h ~; read -n 1"
}

updates_popup() {
    exec_first_available "yay -Syu" "paru -Syu" "sudo pacman -Syu" "sudo apt update && sudo apt upgrade" "sudo dnf upgrade" "brew update && brew upgrade"
}

uptime_popup() {
    exec_first_available "fastfetch; read -n 1" "neofetch; read -n 1" "hyfetch; read -n 1" "uptime; read -n 1"
}

volume_popup() {
    exec_first_available "pulsemixer" "alsamixer" "ncpamixer"
}

if [ "$1" = "--exec" ]; then
    shift
    eval "$@"
    exit $?
fi

side="$1"        # "left", "right", or "center"
mouse_x="$2"     # #{mouse_x}
client_w="$3"    # #{client_width}
mouse_range="$4" # #{mouse_status_range}

declare -A default_popups=(
    ["bandwidth"]="bandwidth_popup"
    ["battery"]="battery_popup"
    ["cpu"]="cpu_popup"
    ["cpu-temp"]="cpu_temp_popup"
    ["cwd"]="cwd_popup"
    ["docker"]="docker_popup"
    ["git"]="git_popup"
    ["github"]="github_popup"
    ["gpu"]="gpu_popup"
    ["keyboard-layout"]="keyboard_layout_popup"
    ["mise"]="mise ls"
    ["network"]="network_popup"
    ["ping"]="ping_popup"
    ["ram"]="ram_popup"
    ["session"]="tea"
    ["storage"]="storage_popup"
    ["tdo"]="tdo -t"
    ["time"]="calcurse"
    ["updates"]="updates_popup"
    ["uptime"]="uptime_popup"
    ["volume"]="volume_popup"
    ["weather"]="curl -s wttr.in; read -n 1"
    ["window-list"]="tea -p"
)

# Popup mode: "popup" (tmux display-popup) or "direct" (execute in background)
declare -A default_popup_types=(
    ["keyboard-layout"]="direct"
    ["session"]="direct"
    ["window-list"]="direct"
)

plugin=""

# Check native tmux status range for instant 0ms plugin detection
if [ -n "$mouse_range" ] && [ "$mouse_range" != "left" ] && [ "$mouse_range" != "right" ] && [ "$mouse_range" != "none" ]; then
    if [ "$mouse_range" = "window" ]; then
        plugin="window-list"
    else
        plugin="${mouse_range#user_}"
        plugin="${plugin#user|}"
    fi
fi

if [ -z "$plugin" ]; then
    if [ "$side" = "center" ] || [ "$side" = "window" ]; then
        plugin="window-list"

    elif [ "$side" = "left" ]; then
        lplugins_str=$(get_tmux_option "@tmux2k-left-plugins" "session git cwd")
        IFS=' ' read -r -a lplugins <<<"$lplugins_str"
        show_powerline=$(get_tmux_option "@tmux2k-show-powerline" true)
        padding=2
        $show_powerline && padding=3

        cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/tmux2k"
        curr_x=0
        for pl in "${lplugins[@]}"; do
            if [ -f "$cache_dir/$pl" ]; then
                output=$(<"$cache_dir/$pl")
            elif [[ "$pl" =~ ^group([0-9]+)$ ]]; then
                output=$(GROUP_NUM="${BASH_REMATCH[1]}" "$current_dir/../plugins/group.sh" 2>/dev/null)
            elif [ -f "$current_dir/../plugins/${pl}.sh" ]; then
                output=$("$current_dir/../plugins/${pl}.sh" 2>/dev/null)
            else
                output=""
            fi

            # Strip tmux style/color sequences (e.g. #[fg=...]) for accurate visible length
            clean_output=$(printf '%s' "$output" | sed -E 's/#\[[^]]*\]//g')
            if [ -n "$clean_output" ]; then
                len=$((${#clean_output} + padding))
            else
                len=10
            fi

            next_x=$((curr_x + len))
            if [ "$mouse_x" -ge "$curr_x" ] && [ "$mouse_x" -lt "$next_x" ]; then
                plugin="$pl"
                break
            fi
            curr_x=$next_x
        done

    elif [ "$side" = "right" ]; then
        rplugins_str=$(get_tmux_option "@tmux2k-right-plugins" "tdo cpu ram storage volume battery network time")
        IFS=' ' read -r -a rplugins <<<"$rplugins_str"
        show_powerline=$(get_tmux_option "@tmux2k-show-powerline" true)
        padding=2
        $show_powerline && padding=3

        cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/tmux2k"
        curr_x=$client_w
        for ((i = ${#rplugins[@]} - 1; i >= 0; i--)); do
            pl="${rplugins[$i]}"
            if [ -f "$cache_dir/$pl" ]; then
                output=$(<"$cache_dir/$pl")
            elif [[ "$pl" =~ ^group([0-9]+)$ ]]; then
                output=$(GROUP_NUM="${BASH_REMATCH[1]}" "$current_dir/../plugins/group.sh" 2>/dev/null)
            elif [ -f "$current_dir/../plugins/${pl}.sh" ]; then
                output=$("$current_dir/../plugins/${pl}.sh" 2>/dev/null)
            else
                output=""
            fi

            # Strip tmux style/color sequences (e.g. #[fg=...]) for accurate visible length
            clean_output=$(printf '%s' "$output" | sed -E 's/#\[[^]]*\]//g')
            if [ -n "$clean_output" ]; then
                len=$((${#clean_output} + padding))
            else
                len=10
            fi

            prev_x=$((curr_x - len))
            if [ "$mouse_x" -ge "$prev_x" ] && [ "$mouse_x" -lt "$curr_x" ]; then
                plugin="$pl"
                break
            fi
            curr_x=$prev_x
        done
    fi
fi

if [ -z "$plugin" ]; then
    exit 0
fi

default_cmd="${default_popups[$plugin]}"
cmd=$(get_tmux_option "@tmux2k-${plugin}-popup-cmd" "$default_cmd")

default_type="${default_popup_types[$plugin]:-popup}"
popup_type=$(get_tmux_option "@tmux2k-${plugin}-popup-type" "$default_type")

if [ -n "$cmd" ]; then
    if [ "$popup_type" = "direct" ]; then
        eval "$cmd" &
    else
        width=$(get_tmux_option "@tmux2k-popup-width" "85%")
        height=$(get_tmux_option "@tmux2k-popup-height" "85%")
        tmux display-popup -E -d "#{pane_current_path}" -w "$width" -h "$height" "$current_dir/popup_handler.sh --exec \"$cmd\""
    fi
fi
