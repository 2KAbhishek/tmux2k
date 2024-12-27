#!/usr/bin/env bash

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir"/utils.sh

network_name="en0"

if [[ $(uname -s) == "Darwin" ]]; then
    network_name=$(get_tmux_option "@tmux2k-network-name" "en0")
elif [[ $(uname -s) == "Linux" ]]; then
    network_name=$(get_tmux_option "@tmux2k-network-name" "wlo1")
else
    # TODO: update this for windows
    echo "Unknown operating system"
    exit 1
fi

network_name=$(get_tmux_option "@tmux2k-network-name" "en0")

get_output_rate(){
    bps=$1
    if [ "$bps" -gt 1073741824 ]; then
        output=$(echo "$bps 1024" | awk '{printf "%4d\n", $1/($2 * $2 * $2)}')
        output+="G"
    elif [ "$bps" -gt 1048576 ]; then
        output=$(echo "$bps 1024" | awk '{printf "%4d\n", $1/($2 * $2)}')
        output+="M"
    else
        output=$(echo "$bps 1024" | awk '{printf "%4d\n", $1/$2}')
        output+="K"
    fi
	echo "${output}"
}

main() {
    RATE=$(get_tmux_option "@tmux2k-refresh-rate" 5) # seconds
    while true; do
        output_download=""
        output_upload=""
        output_download_unit=""
        output_upload_unit=""

        if [[ $(uname -s) == "Linux" ]]; then
            initial_download=$(cat /sys/class/net/"$network_name"/statistics/rx_bytes)
            initial_upload=$(cat /sys/class/net/"$network_name"/statistics/tx_bytes)

            sleep "$RATE"

            final_download=$(cat /sys/class/net/"$network_name"/statistics/rx_bytes)
            final_upload=$(cat /sys/class/net/"$network_name"/statistics/tx_bytes)
        else
            initial_download=$(netstat -I "$network_name" -b | tail -n 1 | awk '{print $7}')
            initial_upload=$(netstat -I "$network_name" -b | tail -n 1 | awk '{print $10}')

            sleep $RATE

            final_download=$(netstat -I "$network_name" -b | tail -n 1 | awk '{print $7}')
            final_upload=$(netstat -I "$network_name" -b | tail -n 1 | awk '{print $10}')
        fi

        total_download_bytes=$(expr "$final_download" - "$initial_download")
        total_upload_bytes=$(expr "$final_upload" - "$initial_upload")
        total_download_bps=$(expr "$total_download_bytes" / "$RATE")
        total_upload_bps=$(expr "$total_upload_bytes" / "$RATE")

        output_download=$(get_output_rate $total_download_bps)
        output_upload=$(get_output_rate $total_upload_bps)

        echo "${output_upload}${output_download}"
    done
}
main
