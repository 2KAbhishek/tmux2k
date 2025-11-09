#!/usr/bin/env bash

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir/../lib/utils.sh"

trim() {
    printf '%s' "${1}" | tr -d '[:space:]'
}

choose_icon() {
    local os_id="$1"

    case "$os_id" in
        arch|endeavouros|manjaro)
            printf '󰣇'
            ;;
        debian|linuxmint|raspbian)
            printf '󰣚'
            ;;
        ubuntu|pop|elementary|zorin)
            printf '󰕈'
            ;;
        darwin)
            printf ''
            ;;
        *)
            printf ''
            ;;
    esac
}

get_arch_updates() {
    local repo_count=0 aur_count=0

    if command -v checkupdates >/dev/null 2>&1; then
        repo_count="$(checkupdates 2>/dev/null | wc -l || echo 0)"
    elif command -v pacman >/dev/null 2>&1; then
        repo_count="$(pacman -Qu --quiet 2>/dev/null | wc -l || echo 0)"
    fi

    if command -v yay >/dev/null 2>&1; then
        aur_count="$(yay -Qua --quiet 2>/dev/null | wc -l || echo 0)"
    fi

    repo_count="$(trim "$repo_count")"
    aur_count="$(trim "$aur_count")"

    [[ "$repo_count" =~ ^[0-9]+$ ]] || repo_count=0
    [[ "$aur_count" =~ ^[0-9]+$ ]] || aur_count=0

    if [ "$aur_count" -gt 0 ]; then
        echo "$ICON [$repo_count+$aur_count]"
    else
        echo "$ICON [$repo_count]"
    fi
}

get_debian_updates() {
    local count=0

    if command -v apt >/dev/null 2>&1; then
        count="$(
            apt list --upgradable 2>/dev/null \
            | grep -v '^Listing\.' \
            | wc -l || echo 0
        )"
    elif command -v apt-get >/dev/null 2>&1; then
        local line
        line="$(apt-get -s dist-upgrade 2>/dev/null | grep -E '^[0-9]+ upgraded' || true)"
        if [ -n "$line" ]; then
            count="$(printf '%s\n' "$line" | awk '{print $1}' || echo 0)"
        fi
    fi

    count="$(trim "$count")"
    [[ "$count" =~ ^[0-9]+$ ]] || count=0

    echo "$ICON [$count]"
}

get_macos_updates() {
    local brew_count=0

    if command -v brew >/dev/null 2>&1; then
        brew_count="$(brew outdated --quiet 2>/dev/null | wc -l || echo 0)"
    fi

    brew_count="$(trim "$brew_count")"
    [[ "$brew_count" =~ ^[0-9]+$ ]] || brew_count=0

    echo "$ICON [$brew_count]"
}

main() {
    local os_id=""

    if [ -f /etc/os-release ]; then
        . /etc/os-release
        os_id="$ID"
    else
        case "$(uname -s)" in
            Darwin)
                os_id="darwin"
                ;;
        esac
    fi

    ICON="$(choose_icon "$os_id")"

    case "$os_id" in
        arch|endeavouros|manjaro)
            get_arch_updates
            ;;
        debian|linuxmint|raspbian|ubuntu|pop|elementary|zorin)
            get_debian_updates
            ;;
        darwin)
            get_macos_updates
            ;;
        *)
            if command -v apt >/dev/null 2>&1 || command -v apt-get >/dev/null 2>&1; then
                get_debian_updates
            else
                echo "$ICON [0]"
            fi
            ;;
    esac
}

main