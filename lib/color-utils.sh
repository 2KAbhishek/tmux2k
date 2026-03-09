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

    local range
    while :; do
        case "$1" in
            -r|--range) range="$2" ; shift ;;
            *)
                value="$1" ; shift
                colors="$*"
                break ;;
        esac
        shift
    done

    local reverse='false'
    if [ "${colors::1}" != '#' ] ; then
        [ "${colors::1}" = '!' ] &&\
            reverse='true'
        colors="${COLOR_GRADIENTS[${colors#*!}]}"
    fi

    if [ -n "$range" ] ; then
        # value must be converted to a percentage for color indexing
        ! value="$(awk "BEGIN {print int($value / $range * 100)}")" &&\
            return
    else
        # value is a point or decimal percentage
        ! [[ "${value// /}" = *'%' ]] &&\
            ! value="$(awk "BEGIN {print ${value} * 100}")" &&\
                return
        value="$(printf '%.0f' "${value%%\%*}")"
    fi

    [ -z "$value" ] || [ -z "$colors" ] &&\
        return

    if [ "$reverse" = 'true' ] ; then
        local _colors="$colors"
        local c; colors=
        for c in $_colors ; do colors="$c $colors" ; done
    fi
    declare -a colors=($colors)

    # value is always a percentage (range 0-100)
    # We can get color index with: v * num_colors / 100
    local index="$((value * ${#colors[@]} / 100))"
    local color="${colors[$index]}"
    
    # When index is out of range, color is empty.
    # In this case we always assume: v > 100
    [ -z "$color" ] &&\
        color="${colors[-1]}"

    printf '%s' "$color"
}

