#!/usr/bin/env bash

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir/../lib/utils.sh"

verify_mise_command() {
    if ! command -v mise >/dev/null 2>&1; then
        echo "mise missing"
        return 1
    fi
    return 0
}

get_language_icon() {
    local tool="$1"

    case "$tool" in
        node) echo "" ;;
        python) echo "" ;;
        ruby) echo "" ;;
        go) echo "" ;;
        rust) echo "" ;;
        java) echo "" ;;
        php) echo "" ;;
        elixir) echo "" ;;
        erlang) echo "" ;;
        haskell) echo "" ;;
        lua) echo "" ;;
        perl) echo "" ;;
        r) echo "" ;;
        swift) echo "" ;;
        kotlin) echo "" ;;
        scala) echo "" ;;
        clojure) echo "" ;;
        dart) echo "" ;;
        crystal) echo "" ;;
        zig) echo "" ;;
        nim) echo "" ;;
        deno) echo "" ;;
        bun) echo "" ;;
        terraform) echo "󱁢" ;;
        usage) echo "" ;;
        *) echo "$tool" ;;
    esac
}

get_active_versions() {
    local versions max_display icon tool version exclude_tools count path
    path=$(get_pane_dir)

    max_display=$(get_tmux_option "@tmux2k-mise-max-tools" "3")
    exclude_tools=$(get_tmux_option "@tmux2k-mise-exclude-tools" "usage")

    versions=""
    count=0
    while IFS= read -r line && [ "$count" -lt "$max_display" ]; do
        if [ -n "$line" ]; then
            tool=$(echo "$line" | awk '{print $1}')
            version=$(echo "$line" | awk '{print $2}')

            if printf '%s\n' "$exclude_tools" | grep -qw -- "$tool"; then
                continue
            fi

            icon=$(get_language_icon "$tool")

            if [ -z "$versions" ]; then
                versions="$icon $version"
            else
                versions="$versions $icon $version"
            fi
            count=$((count + 1))
        fi
    done <<<"$(mise current --cd "$path" 2>/dev/null | sort)"

    if [ -z "$versions" ]; then
        echo "none"
    else
        echo "$versions"
    fi
}

main() {
    local output

    if ! verify_mise_command; then
        return
    fi

    output="$(get_active_versions)"
    echo "$output"
}

main
