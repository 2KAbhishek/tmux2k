#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly current_dir
source "$current_dir/../lib/utils.sh"

cpu_icon="$(get_tmux_option '@tmux2k-cpu-icon' '')"
cpu_display_load="$(get_tmux_option '@tmux2k-cpu-display-load' 'false')"
cpu_display_usage="$(get_tmux_option '@tmux2k-cpu-display-usage' 'true')"
cpu_gradient="$(get_tmux_option '@tmux2k-cpu-gradient' '')"
cpu_icon_link_to="$(get_tmux_option '@tmux2k-cpu-icon-link-to' '')"
cpu_usage_average="$(get_tmux_option '@tmux2k-cpu-usage-average' '0')"

[ -n "$cpu_gradient" ] &&\
    source "$current_dir/../lib/color-utils.sh"

get_cpu_usage() {
    local cpu_usage_decimal
    cpu_usage_decimal="$(get_tmux_option '@tmux2k-cpu-usage-decimal' 'true')"

    local percent=''
    case "$(uname -s)" in
    Linux)
        local cpu_values
        cpu_values="$(awk '/^cpu / { print $2+$3+$4+$5+$6+$7+$8, $5+$6 }' /proc/stat)"
        percent="$(awk -v cur="$cpu_values" -v prev="$(get_state cpu-stat-prev)" '
            BEGIN {
                split(cur, c); split(prev, p)
                total = c[1] - p[1]
                idle = c[2] - p[2]
                if (total > 0)
                    printf "%.1f", 100 - idle / total * 100
                else
                    printf "%.1f", 100 - c[2] / c[1] * 100
            }')"
        set_state cpu-stat-prev "$cpu_values"
        ;;

    Darwin)
        local cpucores cpuusage cpuvalue
        cpuvalue="$(ps -A -o %cpu | awk -F. '{s+=$1} END {print s}')"
        cpucores="$(getconf _NPROCESSORS_ONLN)"
        cpuusage="$((cpuvalue / cpucores))"
        percent="$cpuusage"
        ;;

    CYGWIN* | MINGW32* | MSYS* | MINGW*) ;; # TODO - windows compatibility
    esac

    [ -z "$percent" ] &&\
        return

    if [ "$cpu_usage_average" -gt '1' ] ; then
        local -a cpu_usage_values=("$percent")
        local -a saved_values
        IFS=' ' read -r -a saved_values <<< "$(get_state cpu-usage-values)"
        cpu_usage_values+=("${saved_values[@]}")

        # We want to get average of n=cpu_usage_average values
        if [ "${#cpu_usage_values[@]}" -gt "$cpu_usage_average" ]; then
            cpu_usage_values=("${cpu_usage_values[@]:0:$cpu_usage_average}")
        fi

        local cpu_usage_string="${cpu_usage_values[*]}"
        percent="$(awk "BEGIN {
            printf \"%.3g\", (${cpu_usage_string// /+}) / $cpu_usage_average
        }")"

        set_state cpu-usage-values "$cpu_usage_string"
    fi

    local output=''
    if [ -n "$cpu_gradient" ] ; then
        local color
        color="$(pct2color "${percent}%" "$cpu_gradient")"
        output+="#[fg=${color:-default}]"
        [ "$cpu_icon_link_to" = 'usage' ] &&\
            set_state cpu-linked-color "$color"
    fi

    if [ "$cpu_usage_decimal" = 'true' ] ; then
        output+="$(normalize_padding "${percent}%" 6)"
    else
        output+="$(normalize_padding "${percent%.*}%" 4)"
    fi

    printf '%s' "$output"
}

normalize_load() {
    local value="$1"
    case "$(uname -s)" in
        Linux | Darwin)
            local cpucores
            cpucores="$(getconf _NPROCESSORS_ONLN)"
            awk "BEGIN {print substr($value / $cpucores, 1, 4)}"
            ;;
        CYGWIN* | MINGW32* | MSYS* | MINGW*) ;; # TODO - windows compatibility
    esac
}

float_to_percent() {
    local value="$1"
    case "$(uname -s)" in
        Linux | Darwin)
            awk "BEGIN {print int($value * 100)\"%\"}"
            ;;
        CYGWIN* | MINGW32* | MSYS* | MINGW*) ;; # TODO - windows compatibility
    esac
}

get_cpu_load() {
    local cpu_load_normalize cpu_load_percent
    cpu_load_normalize="$(get_tmux_option '@tmux2k-cpu-load-normalize' 'true')"
    cpu_load_percent="$(get_tmux_option '@tmux2k-cpu-load-percent' 'true')"

    local -a cpu_load_averages
    IFS=' ' read -r -a cpu_load_averages <<< "$(get_tmux_option '@tmux2k-cpu-load-averages' '1m 5m 15m')"

    declare -a cpu_load_output=()
    case $(uname -s) in
    Linux | Darwin)
        declare -a loadavg=()
        local raw_loadavg
        raw_loadavg=$(uptime | awk -F'[a-z]:' '{ print $2}' | sed 's/,//g')
        IFS=' ' read -r -a loadavg <<< "$raw_loadavg"

        local i avg interval color
        declare -a intervals=('1m' '5m' '15m')
        for ((i = 0; i < "${#intervals[@]}"; i++)); do
            interval="${intervals[$i]}"
            ! [[ " ${cpu_load_averages[*]} " == *" $interval "* ]] &&\
                continue

            avg="${loadavg[$i]}"
            [ "$cpu_load_normalize" = 'true' ] &&\
                avg="$(normalize_load "$avg")"

            [ "$cpu_load_percent" = 'true' ] &&\
                avg="$(float_to_percent "$avg")"

            if [ -n "$cpu_gradient" ] ; then
                color="$(pct2color "$avg" "$cpu_gradient")"
                [ "$cpu_icon_link_to" = "$interval" ] &&\
                    set_state cpu-linked-color "$color"
                color="#[fg=${color:-default}]"
            fi

            cpu_load_output+=("${color}$(normalize_padding "$avg" 4)")
        done
        ;;

    CYGWIN* | MINGW32* | MSYS* | MINGW*) ;; # TODO - windows compatibility
    esac

    printf '%s' "${cpu_load_output[*]}"
}

main() {
    # Two cases for each mode are defined:
    # 1) Display icon and  mode value(s)
    # 2) Display colorized icon only (discard mode output)

    local cpu_usage
    if [ "$cpu_display_usage" = 'true' ] ; then
        cpu_usage="$(get_cpu_usage)"
    elif [ "$cpu_icon_link_to" = 'usage' ] ; then
        get_cpu_usage &>/dev/null
    fi

    local cpu_load
    if [ "$cpu_display_load" = 'true' ] ; then
        cpu_load="$(get_cpu_load)"
    elif [[ "$cpu_icon_link_to" = *'m' ]] ; then
        get_cpu_load &>/dev/null
    fi

    local output=''
    local cpu_linked_color
    if [ -z "$cpu_icon_link_to" ] || [ -z "$cpu_gradient" ] ; then
        # Removes tmux restart requirement on reset
        set_state cpu-linked-color ''
    else
        cpu_linked_color="$(get_state cpu-linked-color '')"
        [ -n "$cpu_linked_color" ] &&\
            output+="#[fg=${cpu_linked_color}]"
    fi

    for s in "$cpu_icon" "$cpu_usage" "$cpu_load" ; do
        [ -n "$s" ] && output+="$s "
    done
    printf '%s' "${output% *}"
}

main

