<div align = "center">

<h1><a href="https://2kabhishek.github.io/tmux2k">tmux2k</a></h1>

<a href="https://github.com/2KAbhishek/tmux2k/blob/main/LICENSE">
<img alt="License" src="https://img.shields.io/github/license/2kabhishek/tmux2k?style=flat&color=eee&label="> </a>

<a href="https://github.com/2KAbhishek/tmux2k/graphs/contributors">
<img alt="People" src="https://img.shields.io/github/contributors/2kabhishek/tmux2k?style=flat&color=ffaaf2&label=People"> </a>

<a href="https://github.com/2KAbhishek/tmux2k/stargazers">
<img alt="Stars" src="https://img.shields.io/github/stars/2kabhishek/tmux2k?style=flat&color=98c379&label=Stars"></a>

<a href="https://github.com/2KAbhishek/tmux2k/network/members">
<img alt="Forks" src="https://img.shields.io/github/forks/2kabhishek/tmux2k?style=flat&color=66a8e0&label=Forks"> </a>

<a href="https://github.com/2KAbhishek/tmux2k/watchers">
<img alt="Watches" src="https://img.shields.io/github/watchers/2kabhishek/tmux2k?style=flat&color=f5d08b&label=Watches"> </a>

<a href="https://github.com/2KAbhishek/tmux2k/pulse">
<img alt="Last Updated" src="https://img.shields.io/github/last-commit/2kabhishek/tmux2k?style=flat&color=e06c75&label="> </a>

<h3>Power & Pizzazz for tmux 🥊💅</h3>

<figure>
  <img src= "images/screenshot.png" alt="tmux2k Demo">
  <br/>
  <figcaption>tmux2k screenshot</figcaption>
</figure>

</div>

## What is this

tmux2k is a `tmux` plugin for that adds `powerline` support and pretty colors to your `tmux` status bar.

## Inspiration

tmux2k was inspired by [dracula/tmux](https://github.com/dracula/tmux).

## Prerequisites

Before you begin, ensure you have met the following requirements:

-   You have installed the latest version of `tmux`.
-   [tpm](https://github.com/tmux-plugins/tpm) for managing `tmux` plugins.
-   A [patched nerd font](https://www.nerdfonts.com/) for `powerline` and glyphs support.

## Installing tmux2k

Using `tpm`

If you are a `tpm` user, you can install the theme and keep up to date by adding the following to your `.tmux.conf` file:

```bash
set -g @plugin 'dracula/tmux'

```

Add any configuration options below this line in your tmux config.

### Activating tmux2k

-   Make sure run -b `~/.tmux/plugins/tpm/tpm` is at the bottom of your `.tmux.conf`
-   Run `tmux`
-   Use the `tpm` install command: prefix + I (default prefix is `ctrl+b`)

## Configuring tmux2k

```bash
# Tmux 2K default configs
# available plugins: battery, cpu-usage, git, gpu-usage, ram-usage, network, network-bandwidth, network-ping, weather, time
set -g @tmux2k-left-plugins "git cpu-usage ram-usage"
set -g @tmux2k-right-plugins "battery network time"
set -g @tmux2k-show-powerline true
set -g @tmux2k-show-fahrenheit false
set -g @tmux2k-military-time true
set -g @tmux2k-border-contrast true

# available colors: white, gray, dark_gray, light_purple, dark_purple, cyan, green, orange, red, pink, yellow
set -g @tmux2k-[plugin-name]-colors "[background] [foreground]"
set -g @tmux2k-cpu-usage-colors "blue dark_gray"

# it can accept `session`, `rocket`, `window`, or any character.
set -g @tmux2k-show-left-icon ""

# update powerline symbols
set -g @dracula-show-left-sep ""
set -g @dracula-show-right-sep ""

# change refresh rate
set -g @dracula-refresh-rate 5
```

## How it was built

tmux2k was built using `neovim`, `shellcheck`, `shellcheck`.

## What I learned

-   Learned a lot about the `tmux` and `tpm` ecosystem.
-   Did some fancy shell scripting.

## What's next

Planning to add `<feature/module>`.

### To-Do

-   [ ] Fix left plugins color logic

Hit the ⭐ button if you found this useful.

## More Info

<div align="center">

<a href="https://github.com/2KAbhishek/tmux2k">Source</a> | <a href="https://2kabhishek.github.io/tmux2k">Website</a>

</div>
