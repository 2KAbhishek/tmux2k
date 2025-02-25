#!/usr/bin/env bash

current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$current_dir/../lib/utils.sh"

session_icon=$(get_tmux_option "@tmux2k-session-icon" "")
session_format=$(get_tmux_option "@tmux2k-session-format" "#S") # `#W` for window

# Define actual color values

main() {
	colors=('#3dd50a' '#000000') # green for bg, black for text from plugin_colors["session"]="green text"
	prefix_highlight='#1688f0'   # blue from default theme
	pl_bg='#000000'              # blue from default theme
	l_sep=$(get_tmux_option "@tmux2k-left-separator" "")

	if [ $prefix_highlight == $pl_bg ]; then
		echo "#[fg=${colors[1]},bg=${colors[0]}] $session_icon $session_format"
	else
		# echo "#[fg=${pl_bg},bg=${prefix_highlight}]#{?client_prefix,#[bg=${prefix_highlight}],} 1 $session_icon $session_format #[fg=${pl_bg},bg=${colors[0]}]#{?client_prefix,#[bg=${prefix_highlight}],} Red"
		echo "#[fg=${colors[1]},bg=${colors[0]}]#{?client_prefix,#[bg=${prefix_highlight}],} $session_icon $session_format #[fg=${colors[0]},bg=${pl_bg}]#{?client_prefix,#[fg=${prefix_highlight}],}${l_sep}"
	fi
}

main
