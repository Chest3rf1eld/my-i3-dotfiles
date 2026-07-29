# my-i3-dotfiles

Личный конфиг рабочего окружения на i3 (X11). Каждая директория верхнего уровня повторяет структуру `$HOME` (например, `i3/.config/i3/config`), что совместимо с [GNU Stow](https://www.gnu.org/software/stow/) — можно засимлинковать каждый пакет отдельно (`stow alacritty`, `stow i3`, и т.д.) или разложить вручную.

## Что внутри

- **i3** — оконный менеджер, кастомная цветовая схема "Ember" (тёплая графитово-янтарная палитра)
- **polybar** — статус-бар
- **picom** — композитор (тени, прозрачность, анимации)
- **rofi** — лаунчер/меню
- **alacritty** — терминал
- **tmux** — мультиплексор терминала, плагины через `tpm` (submodules): `tmux-resurrect`, `tmux-continuum`, `tmux-gruvbox`
- **zshrc** — Oh My Zsh + Powerlevel10k
- **systemd** — пользовательские unit-файлы
- **scripts** — вспомогательные утилиты: переключение лимита заряда батареи, блокировка экрана, скриншоты (в буфер/файл), автозапуск v2rayN, ротация обоев

## Установка

```sh
git clone --recurse-submodules <repo-url>
cd my-i3-dotfiles
# через GNU Stow (если установлен):
stow alacritty i3 picom polybar rofi scripts systemd tmux zshrc
```

Нужны установленные i3, polybar, picom, rofi, alacritty, tmux, zsh + oh-my-zsh + powerlevel10k.
