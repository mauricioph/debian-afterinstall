#!/bin/bash
#
#
#

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi


nonfree=$(cat /etc/apt/sources.list | grep deb | sed '/^#/d' | awk 'NF>2{print $NF}' | sed -n 1p)

if [ -z "$nonfree" ]
then cat /etc/apt/sources.list | grep deb | sed 's/main/main\ contrib\ non-free/g' > /tmp/.source.list
mv /etc/apt/source.list /etc/apt/source.list.$(date +%d-%m-%Y).bk
mv /tmp/.source.list /etc/apt/source.list
else echo "already non-free and contrib repo installed"
fi

for i in *.list
do if [ ! -f /etc/apt/source.list.d/${i} ]
mv ${i} /etc/apt/source.list.d/
else echo "${i} is already in place"
fi
done

apt install debian-keyring -y
wget -q https://downloads.plex.tv/plex-keys/PlexSign.key -O - | sudo apt-key add -
wget -O - http://download.videolan.org/pub/debian/videolan-apt.asc | sudo apt-key add -
wget -q -O - https://apt.mopidy.com/mopidy.gpg | sudo apt-key add -
wget http://www.webmin.com/jcameron-key.asc
apt-key add jcameron-key.asc


apt install apt-transport-https
apt install webmin
apt update
apt upgrade -y

superuserdo=$(which sudo)
if [ -z ${superuserdo} ]
then apt install sudo
echo "Which user should be in sudo?"
read -s usuario
usermod -a -G sudo $usuario
fi

apt install synaptic apt-xapian-index gdebi gksu -y
apt install firmware-linux -y
apt install ttf-freefont ttf-mscorefonts-installer -y
apt install fonts-noto -y
apt install qt4-qtconfig -y
apt install file-roller evince doidon qalculate clementine vlc gimp shotwell gparted gnome-disk-utility libreoffice-writer libreoffice-calc libreoffice-impress -y
apt install ufw gufw -y
apt install libavcodec-extra ffmpeg -y
apt install pavucontrol audacity jackd mixxx ncmpdcpp -y
apt install network-manager-gnome openssh-server openssl openvpn samba perl phpmyadmin sqlite3 -y
apt install apt-show-versions libio-pty-perl libauthen-pam-perl -y
apt install git install asciidoc xmlto --no-install-recommends -y
apt install uuid-dev libattr1-dev zlib1g-dev libacl1-dev e2fslibs-dev libblkid-dev liblzo2-dev -y
apt install rsync tg3 firmware-linux-nonfree gparted ntfs* testdisk gdebi -y
apt install libreoffice imagemagick swftools ghostscript pdftohtml ffmpeg  -y
apt install default-jre software-properties-common dirmngr ranger restartd -y
apt install imagemagick smartmontools fdupes zbackup -y
apt install libreoffice tesseract-ocr tesseract-ocr-eng clamav imagemagick ghostscript  -y

ufw reset 
ufw default deny
ufw allow SSH
ufw allow "WWW full"
ufw allow "WWW Cache"
ufw allow Samba
ufw allow CIFS
ufw allow webmin

ufw enable
ufw status
