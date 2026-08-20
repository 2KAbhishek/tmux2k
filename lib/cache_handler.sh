#!/usr/bin/env bash

# Non-blocking plugin output caching
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
            [ $((now - ltime)) -lt 30 ] && lock_active=true
        fi

        [ $((now - mtime)) -ge "$refresh_rate" ] && [ "$lock_active" = false ] && ("$0" >"$lock_file" && mv "$lock_file" "$cache_file") &
        cat "$cache_file"
        exit 0
    else
        [ -d "$cache_dir" ] || mkdir -p "$cache_dir"
        "$0" >"$lock_file" && mv "$lock_file" "$cache_file"
        cat "$cache_file"
        exit 0
    fi
fi

# Plugin state persistence (transient tmpfs or cache)
if [ -n "$XDG_RUNTIME_DIR" ] && [ -d "$XDG_RUNTIME_DIR" ]; then
    state_dir="$XDG_RUNTIME_DIR/tmux2k/state"
else
    state_dir="${XDG_CACHE_HOME:-$HOME/.cache}/tmux2k/state"
fi

get_state() {
    if [ -f "$state_dir/$1" ]; then
        local val
        val=$(<"$state_dir/$1")
        printf '%s' "${val:-$2}"
    else
        printf '%s' "$2"
    fi
}

set_state() {
    [ -d "$state_dir" ] || mkdir -p "$state_dir"
    local tmp="$state_dir/.$1.$$"
    printf '%s' "$2" >"$tmp" && mv -f "$tmp" "$state_dir/$1"
}
