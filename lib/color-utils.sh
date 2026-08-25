#!/usr/bin/env bash

declare -A COLOR_GRADIENTS=(
    # Standard Gradients
    ['heat']='#6673bc #5da9bc #54bd8e #56bd4c #78bd47 #9ebd43 #beb53e #be8b3a #be5d35 #be3136'
    ['heat-dark']='#454e80 #3f7380 #387d5e #3a8033 #518030 #6b802d #80781c #8c611d #8a3f20 #8c161b'
    ['cosmic']='#6673bc #705dbc #8e54bd #b24cbd #bd47b3 #bd439e #be3e86 #be3a6d #be3552 #be3136'
    ['cosmic-dark']='#454e80 #4c3f80 #603980 #783380 #803079 #802d6b #802a5a #802749 #802437 #802124'
    # Themed Gradients
    ['catppuccin']='#8aadf4 #a6da95 #eed49f #f5a97f #ed8796'
    ['catppuccin-dark']='#405580 #4c6e42 #a68137 #c26a3a #a63a4a'
    ['gruvbox']='#458588 #98971a #fabd2f #d79921 #cc241d'
    ['gruvbox-dark']='#3c6466 #66651f #8f692e #9e5b38 #9e3838'
    ['monokai']='#66d9ef #a6e22e #e6db74 #ffa07a #f92672'
    ['monokai-dark']='#2d6773 #5c7330 #736a1d #99542c #a6305c'
    ['onedark']='#61afef #98c379 #e5c07b #ffa07a #e06c75'
    ['onedark-dark']='#345d80 #506e3c #7a602c #874b34 #8a3339'
)

pct2color() {
    # Usage: pct2color [option ...] VALUE COLORS
    #
    # Returns a hex color from COLORS or COLOR_GRADIENTS based on a
    # given percentage, fraction, or range.
    #
    # Positional Args:
    #  VALUE   Value to measure. If value is not format 'X[.Y]%', a
    #          fraction is assumed. If range is given, then value
    #          becomes: value / range
    #  COLORS  Space-separated list of hex colors, or the name of a
    #          named gradient. Prepending a named gradient with '!'
    #          will reverse its colors.
    #
    # Options:
    #  -r, --range NUM
    #          Defines the ceiling of a range from 0 to NUM, where
    #          VALUE becomes a number in range.
    #
    # Example:
    #  pct2color '66%'      '#0000ff #00ff00 #ff0000' => '#ff0000'
    #  pct2color -r 200 100 '#0000ff #ff0000'         => '#ff0000'
    #  pct2color 0.25       'heat'                    => heat[3] (#54bd8e)
    #  pct2color 0.1%       '!heat'                   => heat[9] (#be3136)

    local range value colors
    while :; do
        case "$1" in
        -r | --range)
            range="$2"
            shift
            ;;
        *)
            value="$1"
            shift
            colors="$*"
            break
            ;;
        esac
        shift
    done

    local reverse='false'
    if [ "${colors::1}" != '#' ]; then
        [ "${colors::1}" = '!' ] &&
            reverse='true'
        colors="${COLOR_GRADIENTS[${colors#*!}]}"
    fi

    if [ -n "$range" ]; then
        # value must be converted to a percentage for color indexing
        ! value="$(awk "BEGIN {print int($value / $range * 100)}")" &&
            return
    else
        # value is a point or decimal percentage
        ! [[ "${value// /}" = *'%' ]] &&
            ! value="$(awk "BEGIN {print ${value} * 100}")" &&
            return
        value="$(printf '%.0f' "${value%%\%*}")"
    fi

    [ -z "$value" ] || [ -z "$colors" ] &&
        return

    if [ "$reverse" = 'true' ]; then
        local _colors="$colors"
        local c
        colors=
        for c in $_colors; do colors="$c $colors"; done
    fi
    declare -a colors=($colors)

    # value is always a percentage (range 0-100)
    # We can get color index with: v * num_colors / 100
    local index="$((value * ${#colors[@]} / 100))"
    local color="${colors[$index]}"

    # When index is out of range, color is empty.
    # In this case we always assume: v > 100
    [ -z "$color" ] &&
        color="${colors[-1]}"

    printf '%s' "$color"
}

readonly -a DYNAMIC_COLOR_PALETTE=(
    '#1688f0' # blue
    '#3dd50a' # green
    '#ffd21a' # yellow
    '#FFA500' # orange
    '#bf58ff' # purple
    '#FF69B4' # pink
    '#11dddd' # cyan
    '#ff4a6a' # light_red
    '#20b2aa' # teal
    '#a6da95' # pastel_green
    '#8aadf4' # cornflower_blue
    '#eed49f' # warm_yellow
    '#f5a97f' # soft_orange
    '#b6a0fe' # lavender
    '#f5bde6' # rose
    '#91d7e3' # sky_blue
    '#a6e22e' # lime
    '#ff1493' # deep_pink
    '#00ced1' # turquoise
    '#ff7f50' # coral
)

match_dynamic_color() {
    # Usage: match_dynamic_color VALUE RULES [OUT_VAR] [CUSTOM_PALETTE]
    #
    # Matches VALUE against RULES and assigns or returns a color (hex, named, or tmux color).
    # If RULES is 'auto' or contains 'auto', hashes VALUE to a distinct palette color (0 subshells).
    #
    # Positional Args:
    #  VALUE           String value to match (e.g. session name, branch name, path).
    #  RULES           Space or comma separated list of pattern=color pairs (e.g. "prod*=red work=blue *=green"),
    #                  or 'auto' for automatic color hashing.
    #  OUT_VAR         Optional variable name to store the resolved color in (0 subshells).
    #  CUSTOM_PALETTE  Optional space-separated list of colors to use for auto-hashing.
    #
    # Example:
    #  match_dynamic_color 'work' 'work=blue personal=green' color_var
    #  match_dynamic_color 'session1' 'auto' color_var

    local _mdc_val="$1"
    local _mdc_rules="$2"
    local _mdc_out_var="$3"
    local _mdc_custom_palette="$4"

    [ -z "$_mdc_val" ] || [ -z "$_mdc_rules" ] && return

    local -a _mdc_p_arr
    if [ -z "$_mdc_custom_palette" ] && declare -p TMUX2K_OPTIONS >/dev/null 2>&1; then
        _mdc_custom_palette="${TMUX2K_OPTIONS['@tmux2k-dynamic-colors-palette']}"
    fi

    if [ -n "$_mdc_custom_palette" ]; then
        read -r -a _mdc_p_arr <<< "$_mdc_custom_palette"
    else
        _mdc_p_arr=("${DYNAMIC_COLOR_PALETTE[@]}")
    fi

    local _mdc_res=""
    _hash_color() {
        local _str="$1"
        local _hash=2166136261 _char _i
        for ((_i = 0; _i < ${#_str}; _i++)); do
            printf -v _char '%d' "'${_str:$_i:1}"
            _hash=$(( ((_hash ^ _char) * 16777619) & 0x7FFFFFFF ))
        done
        local _index=$(( _hash % ${#_mdc_p_arr[@]} ))
        _mdc_res="${_mdc_p_arr[$_index]}"
    }

    if [ "$_mdc_rules" = "auto" ] || [ "$_mdc_rules" = "true" ]; then
        _hash_color "$_mdc_val"
    else
        local IFS=$' \t\n,' _mdc_rule
        for _mdc_rule in $_mdc_rules; do
            [ -z "$_mdc_rule" ] && continue
            local _mdc_pattern="${_mdc_rule%%=*}"
            local _mdc_col="${_mdc_rule#*=}"

            if [ "$_mdc_pattern" = "auto" ] && [ "$_mdc_col" = "auto" ]; then
                _hash_color "$_mdc_val"
                break
            fi

            # shellcheck disable=SC2053
            if [[ "$_mdc_val" == $_mdc_pattern ]]; then
                if [ "$_mdc_col" = "auto" ]; then
                    _hash_color "$_mdc_val"
                else
                    _mdc_res="$_mdc_col"
                fi
                break
            fi
        done
    fi

    if [ -n "$_mdc_out_var" ]; then
        printf -v "$_mdc_out_var" '%s' "$_mdc_res"
    else
        printf '%s' "$_mdc_res"
    fi
}
