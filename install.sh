#!/data/data/com.termux/files/usr/bin/bash

set -Eeuo pipefail
IFS=$'\n\t'

R="$(printf '\033[1;31m')"
G="$(printf '\033[1;32m')"
Y="$(printf '\033[1;33m')"
W="$(printf '\033[1;37m')"
C="$(printf '\033[1;36m')"

CHROOT="$PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu"

banner() {
    clear
    printf '%s████████╗██████╗  ██████╗ ████████╗\n' "$C"
    printf '╚══██╔══╝██╔══██╗██╔═══██╗╚══██╔══╝\n'
    printf '   ██║   ██████╔╝██║   ██║   ██║   \n'
    printf '   ██║   ██╔══██╗██║   ██║   ██║   \n'
    printf '   ██║   ██████╔╝╚██████╔╝   ██║   \n'
    printf '   ╚═╝   ╚═════╝  ╚═════╝    ╚═╝   \n%s' "$W"
    printf '%s                By Technical Bot\n%s' "$Y" "$W"
}

install_ubuntu() {
    printf '\n'
    if [ -d "$CHROOT" ]; then
        printf '%sExisting Ubuntu installation found, Resetting it...%s\n' "$G" "$W"
        proot-distro reset ubuntu
    else
        printf '%sInstalling Ubuntu...%s\n\n' "$G" "$W"
        pkg update -y
        pkg install -y proot-distro
        proot-distro install ubuntu
    fi
}

install_desktop() {
    printf '%sInstalling XFCE Desktop...%s\n' "$G" "$W"
    cat > "$CHROOT/root/.bashrc" <<'EOF'
set -e
apt-get update
apt-get install -y udisks2
rm -f /var/lib/dpkg/info/udisks2.postinst
: > /var/lib/dpkg/info/udisks2.postinst
dpkg --configure -a
apt-mark hold udisks2
apt-get install --no-install-recommends xfce4 -y 
apt-get install gnome-terminal nautilus dbus-x11 tigervnc-standalone-server -y
echo "vncserver -geometry 1280x720 -xstartup /usr/bin/startxfce4" >> /usr/local/bin/vncstart
echo "vncserver -kill :* ; rm -rf /tmp/.X1-lock ; rm -rf /tmp/.X11-unix/X1" >> /usr/local/bin/vncstop
chmod +x /usr/local/bin/vncstart 
chmod +x /usr/local/bin/vncstop 
sleep 2
exit
EOF
    proot-distro login ubuntu
    rm -f "$CHROOT/root/.bashrc"
}

adding_user() {
    printf '%sAdding a User...%s\n' "$G" "$W"
    cat > "$CHROOT/root/.bashrc" <<'EOF'
set -e
apt-get update
apt-get install -y sudo wget
useradd -m -s /bin/bash ubuntu
printf 'ubuntu:ubuntu\n' | chpasswd
printf 'ubuntu ALL=(ALL:ALL) ALL\n' > /etc/sudoers.d/ubuntu
exit
EOF
    proot-distro login ubuntu
    printf 'proot-distro login --user ubuntu ubuntu\n' > "$PREFIX/bin/ubuntu"
    chmod +x "$PREFIX/bin/ubuntu"
    rm -f "$CHROOT/root/.bashrc"
}

install_theme() {
    printf '%sInstalling Theme%s\n' "$G" "$W"
    mv "$CHROOT/home/ubuntu/.bashrc" "$CHROOT/home/ubuntu/.bashrc.bak"
    printf 'wget https://raw.githubusercontent.com/TecnicalBot/modded-distro/main/theme/theme.sh && bash theme.sh && exit\n' > "$CHROOT/home/ubuntu/.bashrc"
    ubuntu
    rm -f "$CHROOT/home/ubuntu/theme.sh"
    rm -f "$CHROOT/home/ubuntu/.bashrc"
    mv "$CHROOT/home/ubuntu/.bashrc.bak" "$CHROOT/home/ubuntu/.bashrc"
    cp "$CHROOT/home/ubuntu/.bashrc" "$CHROOT/root/.bashrc"
    sed -i 's/32/31/g' "$CHROOT/root/.bashrc"
}

install_extra() {
    printf '%sInstalling Extra%s\n' "$G" "$W"
    cat > "$CHROOT/root/.bashrc" <<'EOF'
set -e
printf 'deb http://ftp.debian.org/debian stable main contrib non-free\n' >> /etc/apt/sources.list
apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv-keys 648ACFD622F3D138
apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv-keys 0E98404D386FA1D9
apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv-keys 605C66F00D6C9793
apt update
apt install -y firefox-esr gedit
exit
EOF
    proot-distro login ubuntu
    rm -f "$CHROOT/root/.bashrc"
}

sound_fix() {
    printf '%sFixing Sound...%s\n' "$G" "$W"
    pkg update -y
    pkg install -y x11-repo pulseaudio
    cat > "$HOME/.bashrc" <<'EOF'
pulseaudio --start \
--load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" \
--exit-idle-time=-1
EOF
    mv "$CHROOT/home/ubuntu/.bashrc" "$CHROOT/home/ubuntu/.bashrc.bak"
    cat > "$CHROOT/home/ubuntu/.bashrc" <<'EOF'
vncstart
sleep 4
DISPLAY=:1 firefox &
sleep 10
pkill -f firefox
vncstop
exit
EOF
    ubuntu
    rm -f "$CHROOT/home/ubuntu/.bashrc"
    mv "$CHROOT/home/ubuntu/.bashrc.bak" "$CHROOT/home/ubuntu/.bashrc"
    wget -O "$(find "$CHROOT/home/ubuntu/.mozilla/firefox" -name '*.default-esr')/user.js" \
        https://raw.githubusercontent.com/TecnicalBot/modded-distro/main/fixes/user.js
}

final_banner() {
    banner
    printf '\n%sInstallion completed%s\n\n' "$G" "$W"
    printf 'ubuntu  -  To start Ubuntu\n\n'
    printf 'ubuntu  -  default ubuntu password\n\n'
    printf 'vncstart  -  To start vncserver, Execute inside ubuntu\n\n'
    printf 'vncstop  -  To stop vncserver, Execute inside ubuntu\n\n'
    rm -f "$HOME/install.sh"
}

banner
install_ubuntu
install_desktop
adding_user
install_theme
sound_fix
final_banner

