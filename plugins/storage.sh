#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8

current_dir="${BASH_SOURCE[0]%/*}"
[ "$current_dir" = "${BASH_SOURCE[0]}" ] && current_dir="."
source "$current_dir/../lib/utils.sh"

storage_gradient="$(get_tmux_option '@tmux2k-storage-gradient' '')"

[ -n "$storage_gradient" ] &&
    source "$current_dir/../lib/color-utils.sh"

storage_icon_link_to="$(get_tmux_option '@tmux2k-storage-icon-link-to' '')"

get_storage_data() {
    local path display output=''
    path=$(get_tmux_option "@tmux2k-storage-path" "/")
    display=$(get_tmux_option "@tmux2k-storage-display" "percent")

    local total_size used_size free_size pct_used

    read -r total_size used_size free_size pct_used <<<"$(df -h "$path" 2>/dev/null | awk 'END{print $2, $3, $4, $5}')"

    if [ -z "$pct_used" ]; then
        return
    fi

    case "$display" in
    free)
        output="${free_size}"
        ;;
    used)
        output="${used_size}"
        ;;
    used_total)
        output="${used_size}/${total_size}"
        ;;
    percent | *)
        output="${pct_used}"
        ;;
    esac

    if [ -n "$storage_gradient" ]; then
        local raw_pct color
        raw_pct=$(echo "$pct_used" | tr -d '%')
        color="$(pct2color "${raw_pct}%" "$storage_gradient")"
        output="#[fg=${color:-default}]${output}"
        [ "$storage_icon_link_to" = 'usage' ] &&
            set_state storage-linked-color "$color"
    fi

    printf '%s' "$output"
}

main() {
    local storage_icon storage_info output=''
    storage_icon=$(get_tmux_option "@tmux2k-storage-icon" "󰋊")
    storage_info=$(get_storage_data)

    if [ -z "$storage_icon_link_to" ] || [ -z "$storage_gradient" ]; then
        set_state storage-linked-color ''
    else
        local storage_linked_color
        storage_linked_color="$(get_state storage-linked-color '')"
        [ -n "$storage_linked_color" ] &&
            output+="#[fg=${storage_linked_color}]"
    fi

    output+="$storage_icon $storage_info"
    printf '%s' "$output"
}

main
