#!/usr/bin/env bash

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir/../lib/utils.sh"

display_status=$(get_tmux_option '@tmux2k-git-display-status' 'false')
added_icon=$(get_tmux_option '@tmux2k-git-added-icon' '')
modified_icon=$(get_tmux_option '@tmux2k-git-modified-icon' '')
updated_icon=$(get_tmux_option '@tmux2k-git-updated-icon' '')
deleted_icon=$(get_tmux_option '@tmux2k-git-deleted-icon' '')
repo_icon=$(get_tmux_option '@tmux2k-git-repo-icon' '')
diff_icon=$(get_tmux_option '@tmux2k-git-diff-icon' '')
no_repo_icon=$(get_tmux_option '@tmux2k-git-no-repo-icon' '')

get_changes() {
    declare -i added=0
    declare -i modified=0
    declare -i updated=0
    declare -i deleted=0

    for i in $(git -C "$path" status -s); do
        case $i in
        'A') added+=1 ;;
        'M') modified+=1 ;;
        'U') updated+=1 ;;
        'D') deleted+=1 ;;
        esac
    done

    output=""
    [ $added -gt 0 ] && output+="${added} $added_icon"
    [ $modified -gt 0 ] && output+=" ${modified} $modified_icon"
    [ $updated -gt 0 ] && output+=" ${updated} $updated_icon"
    [ $deleted -gt 0 ] && output+=" ${deleted} $deleted_icon"

    echo "$output"
}

get_pane_dir() {
    nextone="false"
    for i in $(tmux list-panes -F "#{pane_active} #{pane_current_path}"); do
        if [ "$nextone" == "true" ]; then
            echo "$i"
            return
        fi
        if [ "$i" == "1" ]; then
            nextone="true"
        fi
    done
}

check_empty_symbol() {
    symbol=$1
    if [ "$symbol" == "" ]; then
        echo "true"
    else
        echo "false"
    fi
}

check_for_changes() {
    if [ "$(check_for_git_dir)" == "true" ]; then
        if [ "$(git -C "$path" status -s)" != "" ]; then
            echo "true"
        else
            echo "false"
        fi
    else
        echo "false"
    fi
}

check_for_git_dir() {
    if [ "$(git -C "$path" rev-parse --abbrev-ref HEAD)" != "" ]; then
        echo "true"
    else
        echo "false"
    fi
}

get_branch() {
    if [ $(check_for_git_dir) == "true" ]; then
        printf "%.20s " $(git -C "$path" rev-parse --abbrev-ref HEAD)
    else
        echo "$no_repo_icon"
    fi
}

get_message() {
    if [ $(check_for_git_dir) == "true" ]; then
        branch="$(get_branch)"

        if [ $(check_for_changes) == "true" ]; then

            changes="$(get_changes)"

            if [ "${display_status}" == "false" ]; then
                if [ $(check_empty_symbol "$diff_icon") == "true" ]; then
                    echo "${changes} $branch"
                else
                    echo "$diff_icon ${changes} $branch"
                fi
            else
                if [ $(check_empty_symbol "$diff_icon") == "true" ]; then
                    echo "$branch"
                else
                    echo "$diff_icon $branch"
                fi
            fi

        else
            if [ $(check_empty_symbol "$repo_icon") == "true" ]; then
                echo "$branch"
            else
                echo "$repo_icon $branch"
            fi
        fi
    else
        echo "$no_repo_icon"
    fi
}

main() {
    path=$(get_pane_dir)
    get_message
}

main
