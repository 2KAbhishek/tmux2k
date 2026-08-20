#!/usr/bin/env bash

# Global OS detection (0 subshell forks via OSTYPE with uname fallback)
case "${OSTYPE:-$(uname -s)}" in
darwin* | Darwin* | *darwin*) HOST_OS="darwin" ;;
linux* | Linux* | *linux*) HOST_OS="linux" ;;
freebsd* | FreeBSD* | *freebsd*) HOST_OS="freebsd" ;;
*) HOST_OS="linux" ;;
esac

# Non-blocking caching wrapper
if [ "$1" = "--cache" ]; then
    plugin_name="$2"
    refresh_rate="$3"
    cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/tmux2k"
    cache_file="$cache_dir/$plugin_name"
    lock_file="$cache_file.tmp"

    if [ -f "$cache_file" ]; then
        if [ "$HOST_OS" = "darwin" ]; then
            mtime=$(stat -f %m "$cache_file" 2>/dev/null || echo 0)
        else
            mtime=$(stat -c %Y "$cache_file" 2>/dev/null || echo 0)
        fi
        [[ "$mtime" =~ ^[0-9]+$ ]] || mtime=0
        now=${EPOCHSECONDS:-$(date +%s)}

        lock_active=false
        if [ -f "$lock_file" ]; then
            if [ "$HOST_OS" = "darwin" ]; then
                ltime=$(stat -f %m "$lock_file" 2>/dev/null || echo 0)
            else
                ltime=$(stat -c %Y "$lock_file" 2>/dev/null || echo 0)
            fi
            [[ "$ltime" =~ ^[0-9]+$ ]] || ltime=0
            # If the lock file is less than 30 seconds old, another update is in progress
            if [ $((now - ltime)) -lt 30 ]; then
                lock_active=true
            fi
        fi

        if [ $((now - mtime)) -ge "$refresh_rate" ] && [ "$lock_active" = false ]; then
            # Expired and not currently updating: update in background
            ("$0" >"$lock_file" && mv "$lock_file" "$cache_file") &
        fi
        cat "$cache_file"
        exit 0
    else
        # First run: populate cache synchronously
        if [ ! -d "$cache_dir" ]; then
            mkdir -p "$cache_dir"
        fi
        "$0" >"$lock_file" && mv "$lock_file" "$cache_file"
        cat "$cache_file"
        exit 0
    fi
fi

get_tmux_option() {
    local option="$1"
    local default_value="$2"
    local option_value
    option_value=$(tmux show-option -gqv "$option")
    printf '%s\n' "${option_value:-$default_value}"
}

# Persistent per-plugin state, stored in files rather than tmux options.
# A plugin runs inside a status #() job; using `tmux set-option` there forces a
# full window redraw, which re-runs the #() and re-triggers the set — a redraw
# loop that makes the status bar flicker. Files avoid that (and multiply so with
# several clients, since a global option redraws them all).
#
# Prefer $XDG_RUNTIME_DIR (tmpfs, transient, wiped on reboot/logout) for this
# short-lived state; fall back to the cache dir where it is unset (macOS,
# non-systemd, ...). set_state mkdir -p's on every write and get_state defaults
# on a missing file, so a wiped runtime dir just resets state — like a cold start.
if [ -n "$XDG_RUNTIME_DIR" ] && [ -d "$XDG_RUNTIME_DIR" ]; then
    state_dir="$XDG_RUNTIME_DIR/tmux2k/state"
else
    state_dir="${XDG_CACHE_HOME:-$HOME/.cache}/tmux2k/state"
fi

get_state() {
    # $1 = key, $2 = default value
    cat "$state_dir/$1" 2>/dev/null || printf '%s' "$2"
}

set_state() {
    # $1 = key, $2 = value. Atomic write (temp + rename) so concurrent readers
    # (e.g. multiple tmux clients running the same #() job) never see a torn file.
    [ -d "$state_dir" ] || mkdir -p "$state_dir"
    local tmp="$state_dir/.$1.$$"
    printf '%s' "$2" >"$tmp" && mv -f "$tmp" "$state_dir/$1"
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
