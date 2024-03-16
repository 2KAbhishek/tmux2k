#!/bin/bash

INTERVAL="1"

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

main() {
    while true; do
        output_download=""
        output_upload=""
        output_download_unit=""
        output_upload_unit=""

        if [[ $(uname -s) == "Linux" ]]; then
            initial_download=$(cat /sys/class/net/"$network_name"/statistics/rx_bytes)
            initial_upload=$(cat /sys/class/net/"$network_name"/statistics/tx_bytes)

            sleep "$INTERVAL"

            final_download=$(cat /sys/class/net/"$network_name"/statistics/rx_bytes)
            final_upload=$(cat /sys/class/net/"$network_name"/statistics/tx_bytes)
        else
            initial_download=$(netstat -I "$network_name" -b | tail -n 1 | awk '{print $7}')
            initial_upload=$(netstat -I "$network_name" -b | tail -n 1 | awk '{print $10}')

            sleep $INTERVAL

            final_download=$(netstat -I "$network_name" -b | tail -n 1 | awk '{print $7}')
            final_upload=$(netstat -I "$network_name" -b | tail -n 1 | awk '{print $10}')
        fi

        total_download_bps=$(expr "$final_download" - "$initial_download")
        total_upload_bps=$(expr "$final_upload" - "$initial_upload")

        if [ "$total_download_bps" -gt 1073741824 ]; then
            output_download=$(echo "$total_download_bps 1024" | awk '{printf "%.1f \n", $1/($2 * $2 * $2)}')
            output_download_unit="G"
        elif [ "$total_download_bps" -gt 1048576 ]; then
            output_download=$(echo "$total_download_bps 1024" | awk '{printf "%.1f \n", $1/($2 * $2)}')
            output_download_unit="M"
        else
            output_download=$(echo "$total_download_bps 1024" | awk '{printf "%.1f \n", $1/$2}')
            output_download_unit="K"
        fi

        if [ "$total_upload_bps" -gt 1073741824 ]; then
            output_upload=$(echo "$total_download_bps 1024" | awk '{printf "%.1f \n", $1/($2 * $2 * $2)}')
            output_upload_unit="G"
        elif [ "$total_upload_bps" -gt 1048576 ]; then
            output_upload=$(echo "$total_upload_bps 1024" | awk '{printf "%.1f \n", $1/($2 * $2)}')
            output_upload_unit="M"
        else
            output_upload=$(echo "$total_upload_bps 1024" | awk '{printf "%.1f \n", $1/$2}')
            output_upload_unit="K"
        fi

        echo " $output_upload$output_upload_unit  $output_download$output_download_unit"
    done
}
main
