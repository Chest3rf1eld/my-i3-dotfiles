# my-i3-dotfiles

Personal desktop environment config for i3 (X11). Each top-level directory mirrors the `$HOME` layout (e.g. `i3/.config/i3/config`), making the repo [GNU Stow](https://www.gnu.org/software/stow/)-compatible — symlink each package individually (`stow alacritty`, `stow i3`, etc.) or lay the files out by hand.

## What's inside

- **i3** — window manager, with a custom "Ember" color scheme (a warm graphite-and-amber palette)
- **polybar** — status bar
- **picom** — compositor (shadows, transparency, animations)
- **rofi** — launcher/menu
- **alacritty** — terminal
- **tmux** — terminal multiplexer, plugins loaded via `tpm` (submodules): `tmux-resurrect`, `tmux-continuum`, `tmux-gruvbox`
- **zshrc** — Oh My Zsh + Powerlevel10k
- **systemd** — user unit files
- **scripts** — helper utilities: battery charge-limit toggle, screen lock, full-screen and region screenshots (to clipboard and file), v2rayN autostart, wallpaper rotation

## Setup

```sh
git clone --recurse-submodules <repo-url>
cd my-i3-dotfiles
# via GNU Stow (if installed):
stow alacritty i3 picom polybar rofi scripts systemd tmux zshrc
```

Requires i3, polybar, picom, rofi, alacritty, tmux, and zsh + oh-my-zsh + powerlevel10k to be installed.
