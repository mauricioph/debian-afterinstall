#!/bin/bash
#
#
#
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

[ -d /sys/firmware/efi ] && echo "EFI boot on HDD" || echo "Legacy boot on HDD"

echo "Adding contrib non-free list to apt"
cat > /etc/apt/sources.list << EOF
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
wget -q https://dl-ssl.google.com/linux/linux_signing_key.pub
apt-key add linux_signing_key.pub
rm -f linux_signing_key.pub

apt install apt-transport-https
apt update
apt list --upgradable
apt upgrade -y

echo "Adding sudo"
apt install sudo
echo "Which user should be in sudo?"
read -s usuario
usermod -a -G sudo $usuario

echo "Installing systems apps"
apt install synaptic apt-xapian-index gdebi gksu apt-show-versions libio-pty-perl libauthen-pam-perl asciidoc xmlto uuid-dev libattr1-dev e2fsprogs f2fs-tools hfsutils hfsprogs jfsutils reiser4progs xfsprogs xfsdump lm-sensors upower zlib1g-dev libacl1-dev e2fslibs-dev libblkid-dev liblzo2-dev macfanctld unrar htop rofi i3blocks feh compton unclutter nbtscan nmap i3lock zathura suckless surf puddletag sonata alarm-clock-applet lightdm-gtk-greeter lightdm-gtk-greeter-settings light-locker -y

echo "Installing non-free system apps"
apt install default-jre smartmontools fdupes zbackup software-properties-common dirmngr ranger restartd firmware-linux-nonfree gparted ntfs* testdisk gdebi firmware-linux -y

echo "Installing base for i3-gaps"
apt install gcc make dh-autoreconf libxcb-keysyms1-dev libpango1.0-dev libxcb-util0-dev xcb libxcb1-dev libxcb-icccm4-dev libyajl-dev libev-dev libxcb-xkb-dev libxcb-cursor-dev libxkbcommon-dev libxcb-xinerama0-dev libxkbcommon-x11-dev libstartup-notification0-dev libxcb-randr0-dev libxcb-xrm0 libxcb-xrm-dev libxcb-shape0-dev

echo "Installing fonts"
apt install fonts-font-awesome ttf-freefont ttf-mscorefonts-installer fonts-noto qt4-qtconfig -y


echo "Installing Internet of Things apps"
apt install rsync network-manager-gnome openssh-server openssl openvpn samba perl phpmyadmin sqlite3 ufw -y

echo "Installing Office apps"
apt install libreoffice imagemagick swftools ghostscript pdftohtml ffmpeg tesseract-ocr tesseract-ocr-eng clamav imagemagick ghostscript file-roller evince qalculate clementine vlc gimp shotwell gparted gnome-disk-utility libreoffice-writer libreoffice-calc libreoffice-impress -y

echo "Installing Media apps"
sudo apt install mkvtoolnix-gui mplayer lsdvd libdvdcss aegisub dos2unix mksquashfs xwinwrap obs-studio libavcodec-extra ffmpeg pavucontrol murrine audacity jackd mixxx ncmpdcpp -y

function firewallrules(){
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
}

echo "Should I change firewall rules?"
read firewall
case ${firewall} in
	y)
	firewallrules
	;;
	yes)
	firewallrules
	;;
	*)
	echo "Skipping firewall rules"
	;;
esac

echo "Doing git repositories installation on /opt"
cd /opt
mkdir -p /opt/repositories
cd /opt/repositories
sudo git clone https://github.com/tobi-wan-kenobi/bumblebee-status.git
sudo git clone https://github.com/mauricioph/debian-afterinstall.git
git clone https://github.com/Airblader/i3 i3-gaps


function installi3(){
cd /opt/repositories/i3-gaps
autoreconf --force --install
rm -fr build
mkdir -p build && cd build/
../configure --prefix=/usr --sysconfdir=/etc --disable-sanitizers
make -j8
sudo make install
}
echo "Should i3 be compiled now?"
read i3now
case ${i3now} in
	y)
	installi3
	;;
	yes)
	installi3
	;;
	*)
	echo "Skipping i3 compilation"
	;;
esac

cd /opt/repositories
echo "All is installed, here are the programs recently installed"
dpkg-query -l 
