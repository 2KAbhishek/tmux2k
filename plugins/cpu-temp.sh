#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir/../lib/utils.sh"

get_cpu_temp() {
	case $(uname -s) in
	Linux)
		temperature=$(LC_NUMERIC=en_US.UTF-8 sensors | grep -oP 'Tctl:.*?\+\K[0-9.]+')
		normalize_padding "$temperature"
		;;

	Darwin)
		temperature=$(ioreg -r -n "AppleSmartBattery" | grep -i "Temperature" | awk '{print $3/100}')
		normalize_padding "$temperature"
		;;

	CYGWIN* | MINGW32* | MSYS* | MINGW*) ;; # TODO - windows compatibility
	esac
}

round() {
	printf "%.${2}f" "${1}"
}

main() {
	temp_icon=$(get_tmux_option "@tmux2k-cpu-temp-icon" "")
	delimiter=$(get_tmux_option "@tmux2k-cpu-temp-delimiter" ".")
	round=$(get_tmux_option "@tmux2k-cpu-temp-round" false)
	cpu_temp=$(get_cpu_temp)

	if [ "$round" = true ]; then
		cpu_temp=$(round "$cpu_temp" 0)
	else
		cpu_temp=$(round "$cpu_temp" 1)
	fi

	cpu_temp=${cpu_temp/./$delimiter}
	result="$temp_icon $cpu_temp"

	echo -n "$result"
}

main
