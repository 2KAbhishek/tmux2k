#!/usr/bin/env bash

current_dir="${BASH_SOURCE[0]%/*}"
[ "$current_dir" = "${BASH_SOURCE[0]}" ] && current_dir="."
source "$current_dir/../lib/utils.sh"

case "$HOST_OS" in
darwin)
    network_name=$(get_tmux_option "@tmux2k-bandwidth-network-name" "en0")
    ;;
linux)
    default_network_device="wlo1"
    if command -v ip >/dev/null 2>&1; then
        default_network_device=$(ip route show default 2>/dev/null | awk '/default/ {print $5; exit}')
    fi
    network_name=$(get_tmux_option "@tmux2k-bandwidth-network-name" "${default_network_device}")
    ;;
*)
    echo "Unknown operating system"
    exit 1
    ;;
esac

get_output_rate() {
    bps=$1
    if [ "$bps" -gt 1073741824 ]; then
        output=$(echo "$bps 1024" | awk '{printf "%d\n", $1/($2 * $2 * $2)}')
        output+="G"
    elif [ "$bps" -gt 1048576 ]; then
        output=$(echo "$bps 1024" | awk '{printf "%d\n", $1/($2 * $2)}')
        output+="M"
    else
        output=$(echo "$bps 1024" | awk '{printf "%d\n", $1/$2}')
        output+="K"
    fi
    echo "${output}"
}

main() {
    up_icon=$(get_tmux_option "@tmux2k-bandwidth-up-icon" "")
    down_icon=$(get_tmux_option "@tmux2k-bandwidth-down-icon" "")
    previous_rx_bytes=$(get_state bandwidth-rx-bytes "0")
    previous_tx_bytes=$(get_state bandwidth-tx-bytes "0")
    previous_timestamp=$(get_state bandwidth-timestamp "0")
    current_timestamp=$(date +%s)
    output_download=""
    output_upload=""

    if [ "$HOST_OS" = "linux" ]; then
        current_rx_bytes=$(cat /sys/class/net/"$network_name"/statistics/rx_bytes)
        current_tx_bytes=$(cat /sys/class/net/"$network_name"/statistics/tx_bytes)
    else
        current_rx_bytes=$(netstat -I "$network_name" -b | tail -n 1 | awk '{print $7}')
        current_tx_bytes=$(netstat -I "$network_name" -b | tail -n 1 | awk '{print $10}')
    fi

    previous_rx_bytes="${previous_rx_bytes:-0}"
    previous_tx_bytes="${previous_tx_bytes:-0}"
    current_rx_bytes="${current_rx_bytes:-0}"
    current_tx_bytes="${current_tx_bytes:-0}"

    # Do calculations if this isn't the first run
    if [ "$previous_timestamp" != '0' ]; then
        seconds=$((current_timestamp - previous_timestamp))
        [ "$seconds" -le 0 ] && seconds=1

        total_download_bytes=$((current_rx_bytes - previous_rx_bytes))
        total_upload_bytes=$((current_tx_bytes - previous_tx_bytes))
        [ "$total_download_bytes" -lt 0 ] && total_download_bytes=0
        [ "$total_upload_bytes" -lt 0 ] && total_upload_bytes=0

        total_download_bps=$((total_download_bytes / seconds))
        total_upload_bps=$((total_upload_bytes / seconds))
        output_download=$(get_output_rate "$total_download_bps")
        output_upload=$(get_output_rate "$total_upload_bps")
    fi

    echo "$up_icon $output_upload $down_icon $output_download"

    # Set values for the next run
    set_state bandwidth-rx-bytes "$current_rx_bytes"
    set_state bandwidth-tx-bytes "$current_tx_bytes"
    set_state bandwidth-timestamp "$current_timestamp"
}
main
