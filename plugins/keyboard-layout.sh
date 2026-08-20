#!/usr/bin/env bash

current_dir="${BASH_SOURCE[0]%/*}"
[ "$current_dir" = "${BASH_SOURCE[0]}" ] && current_dir="."
source "$current_dir/../lib/utils.sh"

keyboard_layout_icon=$(get_tmux_option "@tmux2k-keyboard-layout-icon" "")
keyboard_layout_format=$(get_tmux_option "@tmux2k-keyboard-layout-format" "short")
keyboard_layout_case=$(get_tmux_option "@tmux2k-keyboard-layout-case" "upper")

get_kde_layout() {
    command -v busctl >/dev/null 2>&1 || return 1

    local idx_raw idx=0
    idx_raw=$(busctl --user call org.kde.keyboard /Layouts org.kde.KeyboardLayouts getLayout 2>/dev/null)
    [[ "$idx_raw" =~ ([0-9]+) ]] || return 1
    idx="${BASH_REMATCH[1]}"

    local list_raw
    list_raw=$(busctl --user call org.kde.keyboard /Layouts org.kde.KeyboardLayouts getLayoutsList 2>/dev/null)
    [ -z "$list_raw" ] && return 1

    local fields=() temp="$list_raw"
    local str_regex='"([^"]+)"'
    while [[ "$temp" =~ $str_regex ]]; do
        fields+=("${BASH_REMATCH[1]}")
        temp="${temp#*\"${BASH_REMATCH[1]}\"}"
    done
    [ "${#fields[@]}" -eq 0 ] && return 1

    local field_offset=0
    [ "$keyboard_layout_format" = "long" ] && field_offset=2

    local target_idx=$((idx * 3 + field_offset))
    if [ -n "${fields[$target_idx]}" ]; then
        printf '%s' "${fields[$target_idx]}"
        return 0
    fi
    return 1
}

get_hyprland_layout() {
    [ -z "$HYPRLAND_INSTANCE_SIGNATURE" ] && return 1
    command -v hyprctl >/dev/null 2>&1 || return 1

    local raw
    raw=$(hyprctl devices -j 2>/dev/null)
    [ -z "$raw" ] && return 1

    local regex='"active_keymap":[[:space:]]*"([^"]+)"'
    if [[ "$raw" =~ $regex ]]; then
        printf '%s' "${BASH_REMATCH[1]}"
        return 0
    fi
    return 1
}

get_sway_layout() {
    [ -z "$SWAYSOCK" ] && return 1
    command -v swaymsg >/dev/null 2>&1 || return 1

    local raw
    raw=$(swaymsg -t get_inputs 2>/dev/null)
    [ -z "$raw" ] && return 1

    local regex='"xkb_active_layout_name":[[:space:]]*"([^"]+)"'
    if [[ "$raw" =~ $regex ]]; then
        printf '%s' "${BASH_REMATCH[1]}"
        return 0
    fi
    return 1
}

get_gnome_layout() {
    command -v gsettings >/dev/null 2>&1 || return 1

    local idx_raw idx=0
    idx_raw=$(gsettings get org.gnome.desktop.input-sources current 2>/dev/null)
    [[ "$idx_raw" =~ ([0-9]+) ]] && idx="${BASH_REMATCH[1]}"

    local sources_raw
    sources_raw=$(gsettings get org.gnome.desktop.input-sources sources 2>/dev/null)
    [ -z "$sources_raw" ] || [ "$sources_raw" = "@a(ss) []" ] && return 1

    local matches=() temp="$sources_raw"
    local str_regex="'([^']+)'"
    while [[ "$temp" =~ $str_regex ]]; do
        local val="${BASH_REMATCH[1]}"
        if [ "$val" != "xkb" ] && [ "$val" != "ibus" ]; then
            matches+=("$val")
        fi
        temp="${temp#*${BASH_REMATCH[0]}}"
    done

    local layout="${matches[$idx]}"
    [ -n "$layout" ] && {
        printf '%s' "$layout"
        return 0
    }
    return 1
}

get_x11_layout() {
    [ -z "$DISPLAY" ] && return 1

    local layout=""
    if command -v xkb-switch >/dev/null 2>&1; then
        layout=$(xkb-switch -p 2>/dev/null)
    fi

    if [ -z "$layout" ] && command -v setxkbmap >/dev/null 2>&1; then
        local raw
        raw=$(setxkbmap -query 2>/dev/null)
        local regex='layout:[[:space:]]*([^[:space:]]+)'
        [[ "$raw" =~ $regex ]] && layout="${BASH_REMATCH[1]}"
    fi

    [ -n "$layout" ] && {
        printf '%s' "$layout"
        return 0
    }
    return 1
}

get_system_layout() {
    command -v localectl >/dev/null 2>&1 || return 1

    local raw layout=""
    raw=$(localectl status 2>/dev/null)
    [ -z "$raw" ] && return 1

    local x11_regex='X11[[:space:]]+Layout:[[:space:]]*([^[:space:]]+)'
    local vc_regex='VC[[:space:]]+Keymap:[[:space:]]*([^[:space:]]+)'

    if [[ "$raw" =~ $x11_regex ]]; then
        layout="${BASH_REMATCH[1]}"
    elif [[ "$raw" =~ $vc_regex ]]; then
        layout="${BASH_REMATCH[1]}"
    fi

    [ -n "$layout" ] && {
        printf '%s' "$layout"
        return 0
    }
    return 1
}

get_darwin_layout() {
    if command -v im-select >/dev/null 2>&1; then
        local im
        im=$(im-select 2>/dev/null)
        if [ -n "$im" ]; then
            printf '%s' "${im##*.}"
            return 0
        fi
    fi

    local raw
    raw=$(defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources 2>/dev/null)
    [ -z "$raw" ] && return 1

    local layout=""
    local kbd_regex='"KeyboardLayout Name"[[:space:]]*=[[:space:]]*"?([^";]+)"?'
    local src_regex='"Component Source Mode"[[:space:]]*=[[:space:]]*"?([^";]+)"?'

    if [[ "$raw" =~ $kbd_regex ]]; then
        layout="${BASH_REMATCH[1]}"
    elif [[ "$raw" =~ $src_regex ]]; then
        layout="${BASH_REMATCH[1]}"
    fi

    [ -n "$layout" ] && {
        printf '%s' "$layout"
        return 0
    }
    return 1
}

main() {
    local layout=""

    # Route based on detected environment
    case "$(get_desktop_environment)" in
    sway) layout=$(get_sway_layout) ;;
    x11) layout=$(get_x11_layout) ;;
    kde) layout=$(get_kde_layout) ;;
    hyprland) layout=$(get_hyprland_layout) ;;
    gnome) layout=$(get_gnome_layout) ;;
    darwin) layout=$(get_darwin_layout) ;;
    esac

    # Fallbacks in priority order: Sway -> X11 -> KDE -> Hyprland -> GNOME -> System
    [ -z "$layout" ] && layout=$(get_sway_layout)
    [ -z "$layout" ] && layout=$(get_x11_layout)
    [ -z "$layout" ] && layout=$(get_kde_layout)
    [ -z "$layout" ] && layout=$(get_hyprland_layout)
    [ -z "$layout" ] && layout=$(get_gnome_layout)
    [ -z "$layout" ] && layout=$(get_system_layout)
    [ -z "$layout" ] && layout="N/A"

    if [ "$keyboard_layout_format" = "short" ] && [ "$layout" != "N/A" ]; then
        layout="${layout%%+*}"
        layout="${layout%%,*}"
        layout="${layout%% *}"
    fi

    case "$keyboard_layout_case" in
    upper | uppercase) layout="${layout^^}" ;;
    lower | lowercase) layout="${layout,,}" ;;
    esac

    if [ -n "$keyboard_layout_icon" ]; then
        echo "$keyboard_layout_icon $layout"
    else
        echo "$layout"
    fi
}

main
