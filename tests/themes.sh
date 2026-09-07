#!/usr/bin/env bash

set -eo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

tmux() {
    return 0
}

source "$repo_dir/main.sh"

assert_theme() {
    local selected_theme="$1"
    local expected="$2"
    local actual

    theme="$selected_theme"
    set_theme

    # shellcheck disable=SC2154 # Variables are assigned by set_theme in main.sh.
    actual="$black $gray $white $light_blue $blue $dark_blue $light_green $green $dark_green $light_orange $orange $dark_orange $light_pink $pink $dark_pink $light_purple $purple $dark_purple $light_red $red $dark_red $light_yellow $yellow $dark_yellow $text $bg_main $bg_alt $message_bg $message_fg $pane_active_border $pane_active_border_bg $pane_border $pane_border_bg $prefix_highlight"

    if [[ "$actual" != "$expected" ]]; then
        printf 'Theme %s did not match its expected palette.\n' "$selected_theme" >&2
        printf 'Expected: %s\n' "$expected" >&2
        printf 'Actual:   %s\n' "$actual" >&2
        return 1
    fi
}

assert_theme "catppuccin-latte" "#dce0e8 #ccd0da #4c4f69 #04a5e5 #1e66f5 #209fb5 #179299 #40a02b #179299 #dc8a78 #fe640b #e64553 #dd7878 #ea76cb #e64553 #7287fd #8839ef #8839ef #e64553 #d20f39 #e64553 #df8e1d #df8e1d #fe640b #dce0e8 #e6e9ef #ccd0da #1e66f5 #dce0e8 #1e66f5 #eff1f5 #ccd0da #eff1f5 #8839ef"
assert_theme "catppuccin-frappe" "#232634 #414559 #c6d0f5 #99d1db #8caaee #85c1dc #81c8be #a6d189 #81c8be #f2d5cf #ef9f76 #ea999c #eebebe #f4b8e4 #ea999c #babbf1 #ca9ee6 #ca9ee6 #ea999c #e78284 #ea999c #e5c890 #e5c890 #ef9f76 #232634 #292c3c #414559 #8caaee #232634 #8caaee #303446 #414559 #303446 #ca9ee6"
assert_theme "catppuccin-macchiato" "#181926 #363a4f #cad3f5 #91d7e3 #8aadf4 #7dc4e4 #8bd5ca #a6da95 #8bd5ca #f4dbd6 #f5a97f #ee99a0 #f0c6c6 #f5bde6 #ee99a0 #b7bdf8 #c6a0f6 #c6a0f6 #ee99a0 #ed8796 #ee99a0 #eed49f #eed49f #f5a97f #181926 #1e2030 #363a4f #8aadf4 #181926 #8aadf4 #24273a #363a4f #24273a #c6a0f6"
assert_theme "catppuccin-mocha" "#11111b #313244 #cdd6f4 #89dceb #89b4fa #74c7ec #94e2d5 #a6e3a1 #94e2d5 #f5e0dc #fab387 #eba0ac #f2cdcd #f5c2e7 #eba0ac #b4befe #cba6f7 #cba6f7 #eba0ac #f38ba8 #eba0ac #f9e2af #f9e2af #fab387 #11111b #181825 #313244 #89b4fa #11111b #89b4fa #1e1e2e #313244 #1e1e2e #cba6f7"
assert_theme "catppuccin" "#1e2030 #3f3f3f #ffffff #91d7e3 #8aadf4 #00008b #8bd5ca #a6da95 #006400 #ffa07a #f5a97f #ff4500 #ffb6c1 #f5bde6 #ff1493 #dda0dd #b6a0fe #4b0082 #ee99a0 #ed8796 #b03060 #fffacd #eed49f #b8860b #1e2030 #1e2030 #3f3f3f #8aadf4 #1e2030 #8aadf4 #1e2030 #3f3f3f #1e2030 #8aadf4"

icons_only=true
show_powerline=true
theme="catppuccin-latte"
set_theme

# shellcheck disable=SC2154 # plugin_colors is declared in main.sh.
if [[ "$show_powerline" != "false" || "${plugin_colors[session]}" != "text green" ]]; then
    printf 'Catppuccin flavors did not apply icons-only styling.\n' >&2
    exit 1
fi

printf 'All Catppuccin theme palettes passed.\n'
