#!/data/data/com.termux/files/usr/bin/sh

#Adding colors
R="$(printf '\033[1;31m')"
G="$(printf '\033[1;32m')"
Y="$(printf '\033[1;33m')"
W="$(printf '\033[1;37m')"
C="$(printf '\033[1;36m')"

CHROOT=$PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu


echo ${G}"Installing Ubuntu..."${W}
echo
pkg update
pkg install proot-distro
proot-distro install ubuntu
echo
install_desktop(){
cat > $CHROOT/root/.bashrc <<- EOF
echo ${G}"Installing XFCE Desktop..."${W}
echo
apt-get update
apt install udisks2 -y
rm -rf /var/lib/dpkg/info/udisks2.postinst
echo "" >> /var/lib/dpkg/info/udisks2.postinst
dpkg --configure -a
apt-mark hold udisks2
apt-get install xfce4 gnome-terminal nautilus dbus-x11 tigervnc-standalone-server -y
echo "vncserver -geometry 1280x720 -xstartup /usr/bin/startxfce4" >> /usr/local/bin/vncstart
echo "vncserver -kill :* ; rm -rf /tmp/.X1-lock ; rm -rf /tmp/.X11-unix/X1" >> /usr/local/bin/vncstop
chmod +x /usr/local/bin/vncstart 
chmod +x /usr/local/bin/vncstop 
sleep 2
exit
echo
EOF
proot-distro login ubuntu 
rm -rf $CHROOT/root/.bashrc
}

adding_user(){
cat > $CHROOT/root/.bashrc <<- EOF
echo ${G}"Adding a User..."${W}
echo
apt-get update
apt-get install sudo -y
sleep 2
useradd -m -s /bin/bash ubuntu
echo "ubuntu:ubuntu" | chpasswd
echo "ubuntu  ALL=(ALL:ALL) ALL" >> /etc/sudoers.d/ubuntu
sleep 2
exit
echo
EOF
proot-distro login ubuntu
echo "proot-distro login --user ubuntu ubuntu" >> $PREFIX/bin/ubuntu
chmod +x $PREFIX/bin/ubuntu
rm $CHROOT/root/.bashrc
}

install_theme(){
echo ${G}"Installing Theme"${W}
mv $CHROOT/home/ubuntu/.bashrc $CHROOT/home/ubuntu/.bashrc.bak
echo "wget https://raw.githubusercontent.com/TecnicalBot/modded-distro/main/theme/theme.sh ; bash  theme.sh; exit" >> $CHROOT/home/ubuntu/.bashrc
ubuntu
rm $CHROOT/home/ubuntu/.bashrc
mv $CHROOT/home/ubuntu/.bashrc.bak $CHROOT/home/ubuntu/.bashrc
cp $CHROOT/home/ubuntu/.bashrc $CHROOT/root/.bashrc
sed -i 's/32/31/g' $CHROOT/root/.bashrc
}

install_extra(){
echo ${G}"Installing Extra"${W}
cat > $CHROOT/root/.bashrc <<- EOF
echo "deb http://ftp.debian.org/debian stable main contrib non-free" >> /etc/apt/sources.list
apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv-keys 648ACFD622F3D138
apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv-keys 0E98404D386FA1D9
apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv-keys 605C66F00D6C9793
apt update
apt install firefox-esr gedit -y
exit
EOF
proot-distro login ubuntu
rm $CHROOT/root/.bashrc
}

install_desktop
install_extra
adding_user
install_theme
