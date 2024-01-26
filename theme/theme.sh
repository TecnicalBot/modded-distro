#!/bin/bash

#Adding colors
R="$(printf '\033[1;31m')"
G="$(printf '\033[1;32m')"
Y="$(printf '\033[1;33m')"
W="$(printf '\033[1;37m')"
C="$(printf '\033[1;36m')"

sudo apt update
sudo apt install yaru-theme-gtk yaru-theme-icon ubuntu-wallpapers ubuntu-wallpapers-jammy ubuntu-wallpapers-impish plank dconf-cli xfce4-panel-profiles xfce4-appmenu-plugin git -y
cd ~
git clone https://github.com/TecnicalBot/modded-distro
cd ~/modded-distro/theme/panel
tar --sort=name --format ustar -cvjhf ubuntu.tar.bz2 config.txt
mkdir -p ~/.local/share/xfce4-panel-profiles/
mv ~/modded-distro/theme/panel/ubuntu.tar.bz2 ~/.local/share/xfce4-panel-profiles/
dbus-launch xfce4-panel-profiles load ~/.local/share/xfce4-panel-profiles/ubuntu.tar.bz2
mkdir -p ~/.config/autostart
mv ~/modded-distro/theme/plank/plank.desktop ~/.config/autostart
mkdir -p ~/.local/share/plank/themes
mkdir -p ~/.config/plank/dock1/
mv ~/modded-distro/theme/plank/launchers ~/.config/plank/dock1/
mv ~/modded-distro/theme/plank/Azeny ~/.local/share/plank/themes


echo
echo ${G}"Create Your VNC Password"${W}
vncstart
sleep 60
vncstop

sleep 10
dbus-launch xfconf-query -c xfce4-desktop -np '/desktop-icons/style' -t 'int' -s '0'
sleep 10
dbus-launch xfconf-query -c xsettings -p /Net/ThemeName -s "Yaru-dark"
sleep 10
dbus-launch xfconf-query -c xfwm4 -p /general/theme -s "Yaru-dark"
sleep 10
dbus-launch xfconf-query -c xsettings -p /Net/IconThemeName -s  "Yaru-dark"
sleep 10
dbus-launch xfconf-query -c xsettings -p /Gtk/CursorThemeName -s "Yaru-dark"
sleep 10
dbus-launch xfconf-query -c xfwm4 -p /general/show_dock_shadow -s false
sleep 10
dbus-launch xfconf-query -c xfce4-desktop -p $(dbus-launch xfconf-query -c xfce4-desktop -l | grep last-image) -s /usr/share/backgrounds/warty-final-ubuntu.png
sleep 10
cat ~/modded-distro/theme/plank/dock.ini | dbus-launch dconf load  /net/launchpad/plank/docks/dock1/
rm -rf ~/modded-distro 



