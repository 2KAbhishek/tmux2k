#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir"/utils.sh

show_fahrenheit=$(get_tmux_option "@tmux2k-show-fahrenheit" false)
show_location=$(get_tmux_option "@tmux2k-show-location" false)
fixed_location=$(get_tmux_option "@tmux2k-fixed-location" "Rampurhat")

declare -A weather_icons=(
    ["Clear"]="󰖙"
    ["Cloud"]=""
    ["Drizzle"]="󰖗"
    ["Fog"]=""
    ["Haze"]="󰼰"
    ["Mist"]=""
    ["Overcast"]=""
    ["Rain"]=""
    ["Sand"]=""
    ["Shower"]=""
    ["Smoke"]=""
    ["Snow"]=""
    ["Sunny"]="󰖙"
    ["Thunderstorm"]=""
    ["Tornado"]="󰼸"
    ["Windy"]="󰖝"
)

display_location() {
    if [[ -n "$fixed_location" ]]; then
        echo "$fixed_location"
    elif $show_location; then
        city=$(curl -s https://ipinfo.io/city 2>/dev/null)
        region=$(curl -s https://ipinfo.io/region 2>/dev/null)
        echo "$city, $region"
    else
        echo ''
    fi
}

fetch_weather_information() {
    if $show_fahrenheit; then
        display_weather='&u'
    else
        display_weather='&m'
    fi
    curl -sL "wttr.in/$fixed_location?format=%C+%t$display_weather"
}

forecast_unicode() {
    local condition=$1
    weather_icon="${weather_icons[$condition]}"
    if [[ -n $weather_icon ]]; then
        echo "$weather_icon "
    else
        echo ' '
    fi
}

display_weather() {
    weather_information=$(fetch_weather_information "$display_weather")

    condition=$(echo "$weather_information" | rev | cut -d ' ' -f2- | tr -d '[:space:]' | rev)
    temperature=$(echo "$weather_information" | rev | cut -d ' ' -f 1 | rev)
    unicode=$(forecast_unicode "$condition")

    echo "$unicode${temperature/+/} $condition"
}

main() {
    # process should be cancelled when session is killed
    if ping -q -c 1 -W 1 ipinfo.io &>/dev/null; then
        echo "$(display_weather) $(display_location)"
    else
        echo "Location Unavailable"
    fi
}

main
