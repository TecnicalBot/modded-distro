#!/bin/bash

set -Eeuo pipefail
IFS=$'\n\t'

export DEBIAN_FRONTEND=noninteractive

BASE_DIR="$HOME/modded-distro"
PANEL_ARCHIVE="$HOME/.local/share/xfce4-panel-profiles/ubuntu.tar.bz2"

sudo apt update
sudo apt install -y \
  yaru-theme-gtk \
  yaru-theme-icon \
  ubuntu-wallpapers \
  ubuntu-wallpapers-jammy \
  ubuntu-wallpapers-impish \
  plank \
  dconf-cli \
  xfce4-panel-profiles \
  xfce4-appmenu-plugin \
  git

rm -rf "$BASE_DIR"
git clone https://github.com/TecnicalBot/modded-distro "$BASE_DIR"

mkdir -p "$HOME/.local/share/xfce4-panel-profiles"

tar --sort=name --format=ustar -cvjhf "$PANEL_ARCHIVE" \
  -C "$BASE_DIR/theme/panel" config.txt

dbus-launch xfce4-panel-profiles load "$PANEL_ARCHIVE"

mkdir -p "$HOME/.config/autostart"
install -m 644 "$BASE_DIR/theme/plank/plank.desktop" "$HOME/.config/autostart/plank.desktop"

mkdir -p "$HOME/.local/share/plank/themes"
mkdir -p "$HOME/.config/plank/dock1"

cp -r "$BASE_DIR/theme/plank/launchers" "$HOME/.config/plank/dock1/"
cp -r "$BASE_DIR/theme/plank/Azeny" "$HOME/.local/share/plank/themes/"

printf '\n\033[1;32mCreate Your VNC Password\033[0m\n'
vncstart
sleep 60
vncstop

dbus-launch xfconf-query -c xfce4-desktop -np /desktop-icons/style -t int -s 0
dbus-launch xfconf-query -c xsettings -p /Net/ThemeName -s Yaru-dark
dbus-launch xfconf-query -c xfwm4 -p /general/theme -s Yaru-dark
dbus-launch xfconf-query -c xsettings -p /Net/IconThemeName -s Yaru-dark
dbus-launch xfconf-query -c xsettings -p /Gtk/CursorThemeName -s Yaru-dark
dbus-launch xfconf-query -c xfwm4 -p /general/show_dock_shadow -s false

BG_KEY="$(dbus-launch xfconf-query -c xfce4-desktop -l | grep last-image | head -n1)"
dbus-launch xfconf-query -c xfce4-desktop -p "$BG_KEY" -s "$BASE_DIR/theme/backgrounds/canvas_by_roytanck.jpg"

dbus-launch dconf load /net/launchpad/plank/docks/dock1/ < "$BASE_DIR/theme/plank/dock.ini"

rm -rf "$BASE_DIR"

