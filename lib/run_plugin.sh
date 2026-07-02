#!/usr/bin/env bash

# Runs a plugin script, honoring an optional per-plugin refresh rate:
#     set -g @tmux2k-<plugin>-refresh-rate 300
# When set, the plugin's output is cached and the script is only re-executed
# after that many seconds. When unset, the plugin runs on every
# status-interval tick (@tmux2k-refresh-rate), as before.
#
# Usage: run_plugin.sh <plugin> [script-path]

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir/utils.sh"

plugin="$1"
script="${2:-$current_dir/../plugins/$plugin.sh}"

refresh_rate=$(get_tmux_option "@tmux2k-${plugin}-refresh-rate" "")

if ! [[ "$refresh_rate" =~ ^[0-9]+$ ]]; then
    exec "$script"
fi

get_mtime() {
    local mtime
    mtime=$(stat -f %m "$1" 2>/dev/null) # BSD/macOS
    [[ "$mtime" =~ ^[0-9]+$ ]] || mtime=$(stat -c %Y "$1" 2>/dev/null) # GNU/Linux
    [[ "$mtime" =~ ^[0-9]+$ ]] || mtime=0
    echo "$mtime"
}

cache_dir="${TMPDIR:-/tmp}/tmux2k-cache"
cache_file="$cache_dir/$plugin"
mkdir -p "$cache_dir"

now=$(date +%s)
if [ -f "$cache_file" ] && [ $((now - $(get_mtime "$cache_file"))) -lt "$refresh_rate" ]; then
    cat "$cache_file"
    exit 0
fi

"$script" >"$cache_file"
cat "$cache_file"
