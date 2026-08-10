#!/usr/bin/env bash

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir/../lib/utils.sh"

keyboard_layout_icon=$(get_tmux_option "@tmux2k-keyboard-layout-icon" "⌨")
keyboard_layout_format=$(get_tmux_option "@tmux2k-keyboard-layout-format" "short")

get_keyboard_layout() {
    command -v busctl >/dev/null 2>&1 || return

    local idx list_raw
    idx=$(busctl --user call org.kde.keyboard /Layouts org.kde.KeyboardLayouts getLayout 2>/dev/null | awk '{print $2}')
    [ -z "$idx" ] && return

    list_raw=$(busctl --user call org.kde.keyboard /Layouts org.kde.KeyboardLayouts getLayoutsList 2>/dev/null)
    [ -z "$list_raw" ] && return

    local fields
    mapfile -t fields < <(grep -o '"[^"]*"' <<<"$list_raw" | sed 's/^"//;s/"$//')

    local field_offset
    case "$keyboard_layout_format" in
    long)
        field_offset=2
        ;;
    short | *)
        field_offset=0
        ;;
    esac

    printf '%s' "${fields[$((idx * 3 + field_offset))]}"
}

main() {
    local layout=""

    case "$(uname -s)" in
    Linux)
        layout=$(get_keyboard_layout)
        ;;
    Darwin) ;; # TODO - macOS support
    CYGWIN* | MINGW32* | MSYS* | MINGW*) ;; # TODO - windows compatibility
    esac

    [ -z "$layout" ] && layout="n/a"

    echo "$keyboard_layout_icon $layout"
}

main
