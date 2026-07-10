#!/usr/bin/env bash

# Non-blocking caching wrapper
if [ "$1" = "--cache" ]; then
    plugin_name="$2"
    refresh_rate="$3"
    platform="$4"
    cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/tmux2k"
    cache_file="$cache_dir/$plugin_name"
    lock_file="$cache_file.tmp"

    if [ -f "$cache_file" ]; then
        if [ "$platform" = "darwin" ]; then
            mtime=$(stat -f %m "$cache_file" 2>/dev/null || echo 0)
        else
            mtime=$(stat -c %Y "$cache_file" 2>/dev/null || echo 0)
        fi
        [[ "$mtime" =~ ^[0-9]+$ ]] || mtime=0
        now=${EPOCHSECONDS:-$(date +%s)}

        lock_active=false
        if [ -f "$lock_file" ]; then
            if [ "$platform" = "darwin" ]; then
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
            ( "$0" > "$lock_file" && mv "$lock_file" "$cache_file" ) &
        fi
        cat "$cache_file"
        exit 0
    else
        # First run: populate cache synchronously
        if [ ! -d "$cache_dir" ]; then
            mkdir -p "$cache_dir"
        fi
        "$0" > "$lock_file" && mv "$lock_file" "$cache_file"
        cat "$cache_file"
        exit 0
    fi
fi


get_tmux_option() {
    local option=$1
    local default_value=$2
    local option_value
    option_value=$(tmux show-option -gqv "$option")
    if [ -z "$option_value" ]; then
        echo "$default_value"
    else
        echo "$option_value"
    fi
}

normalize_padding() {
    percent_len=${#1}
    max_len=${2:-4}
    diff_len=$(( max_len - percent_len ))
    # if the diff_len is even, left will have 1 more space than right
    left_spaces=$(( (diff_len + 1) / 2 ))
    right_spaces=$(( diff_len / 2 ))
    printf "%${left_spaces}s%s%${right_spaces}s\n" "" "$1" ""
}

get_pane_dir() {
    tmux display-message -p -F "#{pane_current_path}" 2>/dev/null
}
