# Ember i3 dotfiles

Personal Linux desktop dotfiles for an **i3-based X11 setup**.

This repository is not an app or framework — it is a **ready-to-use desktop configuration**: window manager, bar, terminal, shell, tmux, launcher, compositor, and helper scripts, all kept in a Stow-friendly layout.

## What this repo is

It configures a full desktop environment built around:
- **i3** for tiling window management
- **polybar** for the status bar
- **picom** for compositing
- **rofi** for launching apps and menus
- **alacritty** for the terminal
- **tmux** for terminal multiplexing
- **zsh** with Oh My Zsh + Powerlevel10k

Theme/style:
- custom **Ember** palette — warm graphite / amber colors across i3, polybar, tmux, and terminal

Extra quality-of-life pieces included:
- volume and brightness **OSD popups**
- lock screen script
- screenshot scripts
- wallpaper rotation from wallpapers stored in this repo
- battery charge-limit toggle
- reading-mode toggle
- user `systemd` units

## Repository layout

Each top-level directory mirrors the target path under `$HOME`.

Examples:
- `i3/.config/i3/config` → `~/.config/i3/config`
- `tmux/.config/tmux/tmux.conf` → `~/.config/tmux/tmux.conf`
- `scripts/.config/scripts/...` → `~/.config/scripts/...`

That makes the repo compatible with [GNU Stow](https://www.gnu.org/software/stow/).

## Packages included

- `i3` — i3 window manager config
- `polybar` — bar config and helper scripts
- `picom` — compositor config
- `rofi` — launcher config
- `dunst` — notification daemon config, themed to match the Ember palette
- `alacritty` — terminal config
- `tmux` — tmux config and TPM plugins
- `zshrc` — shell config
- `systemd` — user services
- `scripts` — utility scripts
- `wallpapers` — wallpaper collection synced into `~/.local/share/wallpapers`
- `claude` — Claude Code settings (incl. desktop notification hook via dunst)
- `gtk` — GTK3/GTK4 dark theme (Adapta-Nokto)

## Installation

Clone with submodules:

```sh
git clone --recurse-submodules <repo-url>
cd my-i3-dotfiles
```

Deploy with GNU Stow:

```sh
stow alacritty claude dunst gtk i3 picom polybar rofi scripts systemd tmux wallpapers zshrc
```

Or copy/symlink files manually if you do not use Stow.

## Requirements

Core tools expected by this setup:
- i3
- polybar
- picom
- rofi
- alacritty
- tmux
- zsh
- Oh My Zsh
- Powerlevel10k

Some helper features also expect tools such as:
- `brightnessctl`
- `wpctl` / `pactl`
- `dunst` / `dunstify`
- `xss-lock`
- `greenclip`
- `xrandr`
- `xclip` or `wl-copy`

## Wallpapers

Wallpapers now live inside this repository under:
- `wallpapers/.local/share/wallpapers`

The wallpaper rotation script reads from:
- the repo copy by default
- or `$WALLPAPER_DIR` if you want to override it

## Notes

- Desktop session target: **X11 + i3**
- The setup is tailored to the author's machine and preferences, but can be reused as a base
- Read files inside each package if you want to adapt specific components

## Russian README

See [README.ru.md](README.ru.md).
