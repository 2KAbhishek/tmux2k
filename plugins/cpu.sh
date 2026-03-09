#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8

readonly current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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
        percent="$(LC_NUMERIC=en_US.UTF-8 top -bn2 -d 0.01 | grep "Cpu(s)" | tail -1 |\
                  sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')"
        ;;

    Darwin)
        local cpuvalues cpucores cpuusage
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
        cpu_usage_values+=($(get_tmux_option '@tmux2k-cpu-usage-values'))

        # We want to get average of n=cpu_usage_average values
        [ "${#cpu_usage_values[@]}" -gt "$cpu_usage_average" ] &&\
            cpu_usage_values=(${cpu_usage_values[@]:0:$cpu_usage_average})

        cpu_usage_values="${cpu_usage_values[*]}"
        percent="$(awk "BEGIN {
            printf \"%.3g\", (${cpu_usage_values// /+}) / $cpu_usage_average
        }")"

        tmux set -g '@tmux2k-cpu-usage-values' "$cpu_usage_values"
    fi

    local output=''
    if [ -n "$cpu_gradient" ] ; then
        local color
        color="$(pct2color "${percent}%" "$cpu_gradient")"
        output+="#[fg=${color:-default}]"
        [ "$cpu_icon_link_to" = 'usage' ] &&\
            tmux set -g '@tmux2k-cpu-linked-color' "$color"
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
    local cpu_load_normalize cpu_load_percent cpu_load_averages
    cpu_load_normalize="$(get_tmux_option '@tmux2k-cpu-load-normalize' 'true')"
    cpu_load_percent="$(get_tmux_option '@tmux2k-cpu-load-percent' 'true')"
    cpu_load_averages=($(get_tmux_option '@tmux2k-cpu-load-averages' '1m 5m 15m'))

    declare -a output=()
    case $(uname -s) in
    Linux | Darwin)
        declare -a loadavg=()
        loadavg+=($(uptime | awk -F'[a-z]:' '{ print $2}' | sed 's/,//g'))

        local i avg interval color
        declare -a intervals=('1m' '5m' '15m')
        for ((i = 0; i < "${#intervals[@]}"; i++)); do
            interval="${intervals[$i]}"
            ! [[ " ${cpu_load_averages[@]} " =~ " $interval " ]] &&\
                continue

            avg="${loadavg[$i]}"
            [ "$cpu_load_normalize" = 'true' ] &&\
                avg="$(normalize_load "$avg")"

            [ "$cpu_load_percent" = 'true' ] &&\
                avg="$(float_to_percent "$avg")"

            if [ -n "$cpu_gradient" ] ; then
                color="$(pct2color "$avg" "$cpu_gradient")"
                [ "$cpu_icon_link_to" = "$interval" ] &&\
                    tmux set -g '@tmux2k-cpu-linked-color' "$color"
                color="#[fg=${color:-default}]"
            fi

            output+=("${color}$(normalize_padding "$avg" 4)")
        done
        ;;

    CYGWIN* | MINGW32* | MSYS* | MINGW*) ;; # TODO - windows compatibility
    esac

    printf '%s' "${output[*]}"
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
        tmux set -g '@tmux2k-cpu-linked-color' ''
    else
        cpu_linked_color="$(get_tmux_option '@tmux2k-cpu-linked-color' '')"
        [ -n "$cpu_linked_color" ] &&\
            output+="#[fg=${cpu_linked_color}]"
    fi

    for s in "$cpu_icon" "$cpu_usage" "$cpu_load" ; do
        [ -n "$s" ] && output+="$s "
    done
    printf '%s' "${output% *}"
}

main

