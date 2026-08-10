#!/usr/bin/env bash

export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

side="$1"     # "left", "right", or "center"
mouse_x="$2"  # #{mouse_x}
client_w="$3" # #{client_width}

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir/utils.sh"

declare -A default_popups=(
    ["bandwidth"]="bmon"
    ["battery"]="btop"
    ["cpu"]="btop"
    ["cpu-temp"]="watch -n 1 -c sensors"
    ["cwd"]="ranger"
    ["docker"]="lazydocker"
    ["git"]="lazygit"
    ["github"]="gh dash"
    ["gpu"]="nvtop"
    ["keyboard-layout"]="command -v busctl >/dev/null 2>&1 && busctl --user --quiet call org.kde.keyboard /Layouts org.kde.KeyboardLayouts getLayout >/dev/null 2>&1 && kcmshell6 kcm_keyboard"
    ["mise"]="mise ls"
    ["network"]="nmtui"
    ["ping"]="gping google.com"
    ["ram"]="htop"
    ["session"]="tea"
    ["storage"]="ncdu --color dark ~"
    ["tdo"]="tdo -t"
    ["time"]="calcurse"
    ["updates"]="yay -Syu"
    ["uptime"]="fastfetch; read -n 1"
    ["volume"]="pulsemixer"
    ["weather"]="curl -s wttr.in; read -n 1"
    ["window-list"]="tea -p"
)

# Popup mode: "popup" (tmux display-popup) or "direct" (execute in background)
declare -A default_popup_types=(
    ["session"]="direct"
    ["window-list"]="direct"
)

plugin=""

# Check native tmux status range for instant 0ms plugin detection
if [[ "$mouse_range" =~ ^user_(.+)$ ]]; then
    plugin="${BASH_REMATCH[1]}"
fi

if [ -z "$plugin" ]; then
    if [ "$side" = "center" ] || [ "$side" = "window" ]; then
        plugin="window-list"

    elif [ "$side" = "left" ]; then
        lplugins_str=$(get_tmux_option "@tmux2k-left-plugins" "session git cwd")
        IFS=' ' read -r -a lplugins <<<"$lplugins_str"

        curr_x=0
        for pl in "${lplugins[@]}"; do
            if [ -f "$current_dir/../plugins/${pl}.sh" ]; then
                output=$("$current_dir/../plugins/${pl}.sh" 2>/dev/null)
                len=$((${#output} + 2))
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

        curr_x=$client_w
        for ((i = ${#rplugins[@]} - 1; i >= 0; i--)); do
            pl="${rplugins[$i]}"
            if [ -f "$current_dir/../plugins/${pl}.sh" ]; then
                output=$("$current_dir/../plugins/${pl}.sh" 2>/dev/null)
                len=$((${#output} + 2))
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
        tmux display-popup -E -d "#{pane_current_path}" -w "$width" -h "$height" "$cmd"
    fi
fi
