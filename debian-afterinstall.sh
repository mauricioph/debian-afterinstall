#!/bin/bash
# Debian after fresh install created for Mauricio at my macbook pro 8.1 (2011)
# (c)2019 Copyleft
#
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

[ -d /sys/firmware/efi ] && echo "EFI boot on HDD" || echo "Legacy boot on HDD"

echo "Adding contrib non-free list to apt"
cat > /etc/apt/source.list << EOF
# Criado por mauricio atraves do script debian-afterinstall.sh
# deb cdrom:[Debian GNU/Linux 9.1.0 _Stretch_ - Official amd64 NETINST 20170722-11:28]/ stretch main
# deb cdrom:[Debian GNU/Linux 9.1.0 _Stretch_ - Official amd64 NETINST 20170722-11:28]/ stretch main

deb http://ftp.uk.debian.org/debian/ stretch main contrib non-free
deb-src http://ftp.uk.debian.org/debian/ stretch main contrib non-free

deb http://security.debian.org/debian-security stretch/updates main
deb-src http://security.debian.org/debian-security stretch/updates main

# stretch-updates, previously known as 'volatile'
deb http://ftp.uk.debian.org/debian/ stretch-updates main contrib non-free
deb-src http://ftp.uk.debian.org/debian/ stretch-updates main contrib non-free

EOF

echo "Adding lists to sources.list.d folder"
for i in ${DIR}/*.list
do  if [ ! -f /etc/apt/sources.list.d/${i} ]
      then mv ${i} /etc/apt/sources.list.d/
      echo "${i} list installed"
      else echo "${i} is already in place"
    fi
done

echo "Getting the signature of the repositories"

apt install debian-keyring -y
wget -q -O - https://downloads.plex.tv/plex-keys/PlexSign.key | apt-key add -
wget -q -O - http://download.videolan.org/pub/debian/videolan-apt.asc | apt-key add -
wget -q -O - https://apt.mopidy.com/mopidy.gpg | apt-key add -
wget -q -O - http://www.webmin.com/jcameron-key.asc | apt-key add -


apt install apt-transport-https
apt update
apt list --upgradable
apt upgrade -y

echo "Adding sudo"
apt install sudo
echo "Which user should be in sudo?"
read -s usuario
usermod -a -G sudo $usuario


apt install synaptic apt-xapian-index gdebi gksu -y
apt install firmware-linux -y

apt install fonts-font-awesome ttf-freefont ttf-mscorefonts-installer -y
apt install fonts-noto -y
apt install qt4-qtconfig -y

apt install file-roller evince qalculate clementine vlc gimp shotwell gparted gnome-disk-utility libreoffice-writer libreoffice-calc libreoffice-impress -y
apt install ufw -y
apt install libavcodec-extra ffmpeg -y
apt install pavucontrol audacity jackd mixxx ncmpdcpp -y
apt install network-manager-gnome openssh-server openssl openvpn samba perl phpmyadmin sqlite3 -y
apt install apt-show-versions libio-pty-perl libauthen-pam-perl -y
apt install git install asciidoc xmlto --no-install-recommends -y
apt install uuid-dev libattr1-dev zlib1g-dev libacl1-dev e2fslibs-dev libblkid-dev liblzo2-dev -y
apt install rsync firmware-linux-nonfree gparted ntfs* testdisk gdebi -y
apt install libreoffice imagemagick swftools ghostscript pdftohtml ffmpeg  -y
apt install default-jre software-properties-common dirmngr ranger restartd -y
apt install imagemagick smartmontools fdupes zbackup -y
apt install libreoffice tesseract-ocr tesseract-ocr-eng clamav imagemagick ghostscript  -y
sudo apt install lm-sensors
sudo apt install upower
sudo apt install mkvtoolnix-gui
sudo apt install macfanctld
sudo apt install htop
sudo apt install rofi i3blocks feh compton unclutter
sudo apt install unrar
sudo apt install e2fsprogs f2fs-tools hfsutils hfsprogs jfsutils reiser4progs xfsprogs xfsdump
sudo apt install nbtscan nmap i3lock zathura suckless surf puddletag sonata alarm-clock-applet lightdm-gtk-greeter lightdm-gtk-greeter-settings light-locker
sudo apt install mplayer lsdvd libdvdcss aegisub dos2unix mksquashfs xwinwrap obs-studio 
sudo apt install gcc make dh-autoreconf libxcb-keysyms1-dev libpango1.0-dev libxcb-util0-dev xcb libxcb1-dev libxcb-icccm4-dev libyajl-dev libev-dev libxcb-xkb-dev libxcb-cursor-dev libxkbcommon-dev libxcb-xinerama0-dev libxkbcommon-x11-dev libstartup-notification0-dev libxcb-randr0-dev libxcb-xrm0 libxcb-xrm-dev libxcb-shape0-dev

sudo apt install murrine

ufw reset 
ufw default deny
ufw allow SSH
ufw allow "WWW full"
ufw allow "WWW secure"
ufw allow "WWW Cache"
ufw allow Samba
ufw allow CIFS
ufw allow webmin

ufw enable
ufw status

cd /opt
mkdir -p /opt/repositories
cd /opt/repositories
sudo git clone https://github.com/tobi-wan-kenobi/bumblebee-status.git
sudo git clone https://github.com/mauricioph/debian-afterinstall.git
git clone https://github.com/Airblader/i3 i3-gaps
cd i3-gaps
autoreconf --force --install
rm -fr build
mkdir -p build && cd build/
../configure --prefix=/opt --sysconfdir=/etc --disable-sanitizers
make -j8
sudo make install
cd /opt/repositories


sudo dpkg-query -l 
