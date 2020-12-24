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
sleep 3
release=$(cat /etc/apt/sources.list | grep "^deb " | awk '{print $3}' | sed -n 1p)

 if(( "${release}" == "stable" ))
then echo "Stable release"
cat > /etc/apt/sources.list << EOF
# Criado por mauricio atraves do script debian-afterinstall.sh
#------------------------------------------------------------------------------#
#                   OFFICIAL UK DEBIAN REPOSITORY
#------------------------------------------------------------------------------#
# Edit these lines below based on the output from this page pointing your country repositories
# https://debgen.simplylinux.ch
#

###### Debian Main Repos
deb http://deb.debian.org/debian/ stable main contrib non-free
deb-src http://deb.debian.org/debian/ stable main contrib non-free

deb http://deb.debian.org/debian/ stable-updates main contrib non-free
deb-src http://deb.debian.org/debian/ stable-updates main contrib non-free

deb http://deb.debian.org/debian-security stable/updates main
deb-src http://deb.debian.org/debian-security stable/updates main

deb http://ftp.debian.org/debian buster-backports main
deb-src http://ftp.debian.org/debian buster-backports main

EOF

else echo "Testing release"
cat > /etc/apt/sources.list << EOF
# Criado por mauricio atraves do script debian-afterinstall.sh
#------------------------------------------------------------------------------#
#                   OFFICIAL UK DEBIAN REPOSITORY
#------------------------------------------------------------------------------#
# Edit these lines below based on the output from this page pointing your country repositories
# https://debgen.simplylinux.ch
#

###### Debian Main Repos
deb http://deb.debian.org/debian/ testing main contrib non-free
deb-src http://deb.debian.org/debian/ testing main contrib non-free

deb http://deb.debian.org/debian/ testing-updates main contrib non-free
deb-src http://deb.debian.org/debian/ testing-updates main contrib non-free

deb http://deb.debian.org/debian-security testing-security main
deb-src http://deb.debian.org/debian-security testing-security main

EOF
fi

echo "Getting the signature of the repositories"
sleep 3
clear
apt install debian-keyring -y
apt install curl wget apt-transport-https dirmngr

wget http://www.deb-multimedia.org/pool/main/d/deb-multimedia-keyring/deb-multimedia-keyring_2016.8.1_all.deb 
dpkg -i deb-multimedia-keyring_2016.8.1_all.deb
curl -s https://updates.signal.org/desktop/apt/keys.asc | apt-key add -
apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 1F3045A5DF7587C3
apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys A87FF9DF48BF1C90
apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 74A941BA219EC810
wget -q https://dl-ssl.google.com/linux/linux_signing_key.pub
apt-key add linux_signing_key.pub
rm -f linux_signing_key.pub
rm -f deb-multimedia-keyring_2016.8.1_all.deb

clear
echo "Preparing for google-chrome"
sleep 3
wget https://dl-ssl.google.com/linux/linux_signing_key.pub
apt-key add linux_signing_key.pub
rm linux_signing_key.pub
cat <<EOF > /etc/apt/sources.list.d/google.list
# wget https://dl-ssl.google.com/linux/linux_signing_key.pub
# sudo apt-key add linux_signing_key.pub
deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main
EOF

clear
echo "Preparing for Skype"
sleep 3
wget https://go.skype.com/skypeforlinux-64.deb
dpkg -i skypeforlinux-64.deb
sleep 5 
rm -f skypeforlinux-64.deb

clear
echo "Preparing for TOR"
sleep 3

cat <<EOF > /etc/apt/sources.list.d/tor.list
# curl https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --import
# gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add -
deb https://deb.torproject.org/torproject.org buster main
deb-src https://deb.torproject.org/torproject.org buster main
EOF

curl https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --import
gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | sudo apt-key add -

apt update
apt install tor 

clear
echo "Installing systems apps"
apt install synaptic apt-xapian-index arandr asciinema atomicparsley  btrfs-progs build-essential busybox bzip2 bzip2-doc ca-certificates  ca-certificates-java ca-certificates-mono cabextract calf-plugins calibre calibre-bin gdebi yad apt-show-versions libio-pty-perl libauthen-pam-perl asciidoc xmlto uuid-dev libattr1-dev e2fsprogs f2fs-tools hfsutils jfsutils reiser4progs xfsprogs xfsdump lm-sensors upower zlib1g-dev libacl1-dev e2fslibs-dev libblkid-dev liblzo2-dev macfanctld unrar htop rofi feh compton unclutter nbtscan nmap i3lock zathura suckless-tools surf puddletag sonata lightdm-gtk-greeter lightdm-gtk-greeter-settings ccd2iso cdparanoia cdrdao certbot cgroupfs-mount light-locker -y
sleep 3

clear
echo "Installing non-free system apps"
sleep 3
apt install amd64-microcode default-jre smartmontools fdupes zbackup dirmngr ranger restartd firmware-linux-nonfree gparted ntfs* testdisk gdebi firmware-linux -y

clear
echo "Installing base for i3-gaps"
sleep 3
apt install gcc make fancontrol read-edid i2c-tools conky-all fonts-font-awesome dh-autoreconf libxcb-keysyms1-dev libpango1.0-dev libxcb-util0-dev xcb libxcb1-dev libxcb-icccm4-dev libyajl-dev libev-dev libxcb-xkb-dev libxcb-cursor-dev libxkbcommon-dev libxcb-xinerama0-dev libxkbcommon-x11-dev libstartup-notification0-dev libxcb-randr0-dev libxcb-xrm0 libxcb-xrm-dev libxcb-shape0-dev libxinerama-dev -y

clear
echo "Installing fonts"
sleep 3
apt install fontconfig fontconfig-config fonts-cantarell fonts-crosextra-caladea fonts-crosextra-carlito fonts-dejavu fonts-dejavu-core fonts-dejavu-extra fonts-droid-fallback fonts-font-awesome fonts-freefont-ttf fonts-glyphicons-halflings fonts-inter fonts-lato fonts-liberation fonts-liberation2 fonts-linuxlibertine fonts-lyx fonts-mathjax fonts-noto fonts-noto-cjk fonts-noto-cjk-extra fonts-noto-color-emoji fonts-noto-core fonts-noto-extra fonts-noto-hinted fonts-noto-mono fonts-noto-ui-core fonts-noto-ui-extra fonts-noto-unhinted fonts-opensymbol fonts-quicksand fonts-roboto-hinted fonts-roboto-unhinted fonts-sil-gentium fonts-sil-gentium-basic fonts-symbola fonts-urw-base35 fonts-wine ttf-bitstream-vera ttf-mscorefonts-installer tzdata -y

clear
echo "Instaling miscelaneuos"
sleep 3
apt install chromium chromium-common chromium-lwn4chrome chromium-sandbox cinnamon-desktop-data cinnamon-l10n cmake cmake-data cmospwd code collectd-core colord colord-data comerr-dev:amd64 comprez compton conky conky-all conky-std console-setup console-setup-linux coreutils cups cups-browsed cups-bsd cups-client cups-common cups-core-drivers cups-daemon cups-filters cups-filters-core-drivers cups-ipp-utils cups-pk-helper cups-ppdc cups-server-common curl darkslide darktable dash davfs2 dos2unix dosfstools dunst dvdauthor e2fsprogs e2fsprogs-l10n easy-rsa easytag ebook-speaker efibootmgr eject exfat-utils exif exifprobe exiftags exiftran f2fs-tools facedetect fakeroot fatcat fdisk fdupes feh ffmpeg fgallery -y

clear
echo "Instaling miscelaneuos 2"
sleep 3
apt install firefox-esr firmware-amd-graphics firmware-linux firmware-linux-free firmware-linux-nonfree firmware-misc-nonfree flac flactag flowblade foomatic-db-compressed-ppds foomatic-db-engine foremost forensics-extra four-in-a-row freepats freerdp2-dev freetype2-doc frei0r-plugins ftp funcoeszz fuse3 fwupd fwupd-amd64-signed ufw unar unrar unrar-free unzip update-glx -y

clear
echo "Instaling miscelaneuos 3"
sleep 3
apt install gdebi gdebi-core gdisk geany geany-common geany-plugin-gproject geany-plugin-projectorganizer geany-plugins-common genisoimage gimp gimp-data gimp-data-extras git git-man gnupg gnupg-agent gnupg-l10n gnupg-utils gparted gperf gpg gpg-agent gpg-wks-client gpg-wks-server gpgconf gpgsm gpgv xscreensaver xscreensaver-data xserver-common xserver-xorg xserver-xorg-core xserver-xorg-input-all xserver-xorg-input-libinput xserver-xorg-input-wacom xserver-xorg-legacy xserver-xorg-video-all xserver-xorg-video-fbdev xterm xtightvncviewer xtrans-dev xxd xz-utils -y

clear
echo "Instaling miscelaneuos 4"
sleep 3
apt install growisofs grub-common grub-efi grub-efi-amd64 grub-efi-amd64-bin grub-efi-amd64-dbg grub-efi-amd64-signed grub2-common gsfonts harvid hcxdumptool hddtemp hdparm heartbleeder hexcompare hexedit hfsutils hicolor-icon-theme hitori horst hostname hping3 htop httrack hwdata hwinfo imagemagick imagemagick-6-common imagemagick-6.q16 zathura zathura-cb zathura-djvu zathura-pdf-poppler zathura-ps zbackup zeitgeist-core zenity zenity-common zip zlib1g  zlib1g-dev zpaq -y

clear
echo "Instaling miscelaneuos 5"
sleep 3
apt install initramfs-tools initramfs-tools-core inkscape install-info installation-report jackd2 jackd2-firewire java-common javascript-common jdupes john john-data kbd keyboard-configuration keyutils krita krita-data -y

clear
echo "Instaling miscelaneuos 6"
sleep 3
apt install lame laptop-detect lsb-base lsb-release lsdvd lshw lsof lua-bitop  lua-cjson  lua-expat  lua-json lua-lpeg  lua-socket  lua5.3 lvm2 lxappearance lxappearance-obconf lxsession lxsession-data lynis lynx lynx-common lz4 lzop m4 mailutils mailutils-common make man-db manpages manpages-dev mariadb-client mariadb-common mcomix mdns-scan media-player-info mediainfo mediainfo-gui memstat mencoder menu menu-xdg -y

clear
echo "Instaling miscelaneuos 7"
sleep 3
apt install mesa-utils mesa-va-drivers  meson mime-support mixxx mixxx-data mkvtoolnix mkvtoolnix-gui moreutils mp3info mpack mpc mpd mpg123 mpg321 mplayer mplayer-gui mplayer-skin-blue mpv mscompress mtools nano nasm nbtscan ncmpcpp ncompress ncurses-base ncurses-bin ncurses-term ndiff netdata net-tools netbase netcat-openbsd netcat-traditional netdiscover netpbm nfs-common nftables ngrep ninja-build nmap nmap-common node-highlight.js node-html5shiv node-jquery node-normalize.css nodejs nodejs-doc nomarch notification-daemon notify-osd nstreams ntfs-3g ntfs-3g-dev -y

clear
echo "Instaling miscelaneuos 8"
sleep 3
apt install openssh-client openssh-server openssh-sftp-server openssl openvpn optipng os-prober osinfo-db oxygen-icon-theme patchage qjackctl qjackrcd qtractor reiser4progs reiserfsprogs samba samba-common samba-common-bin samba-dev  samba-dsdb-modules  samba-libs  samba-vfs-modules  sane-utils sbsigntool scour screenfetch scrot sxiv synaptic sysstat tor torsocks -y

clear
echo "Installing php"
sleep 3
apt install php php-bz2 php-common php-curl php-gd php-google-recaptcha php-imagick php-json php-mbstring php-memcache php-mysql php-pear php-phpmyadmin-motranslator php-phpmyadmin-shapefile php-phpmyadmin-sql-parser php-phpseclib php-psr-cache php-psr-container php-psr-log php-sqlite3 php-symfony-cache php-symfony-cache-contracts php-symfony-expression-language php-symfony-service-contracts php-symfony-var-exporter php-tcpdf php-twig php-twig-extensions php-xml php-zip -y

clear
echo "Installing Internet of Things apps"
sleep 3
apt install rsync openssh-server openssl openvpn samba perl sqlite3 ufw mtools -y

clear
echo "Installing Office apps"
sleep 3
apt install libreoffice scrot feh ghostscript poppler-utils ffmpeg imagemagick ghostscript file-roller evince vlc v4l-utils va-driver-all  vbetool vim-common vim-tiny vinagre vino vlc vlc-bin vlc-data vlc-plugin-access-extra  vlc-plugin-base  vlc-plugin-fluidsynth  vlc-plugin-jack  vlc-plugin-notify  vlc-plugin-qt  vlc-plugin-samba  vlc-plugin-skins2  vlc-plugin-svg  vlc-plugin-video-output  vlc-plugin-video-splitter  vlc-plugin-visualization  vorbis-tools gimp shotwell gparted libreoffice-writer libreoffice-calc libreoffice-impress -y

clear
echo "Installing Media apps"
sleep 3
apt install blender blender-data blueman  bluetooth bluez bluez-obexd python-psutil python-power upower x11-xserver-utils mkvtoolnix-gui mplayer lsdvd libdvd-pkg aegisub dos2unix squashfs-tools obs-plugins obs-studio libavcodec-extra ffmpeg pavucontrol audacity mixxx ncmpcpp sox -y

function nextcloud(){
apt install mlocate apache2 libapache2-mod-php mariadb-client mariadb-server wget unzip bzip2 curl php php-common php-curl php-gd php-mbstring php-mysql php-xml php-zip php-intl php-apcu php-redis php-http-request

cat <<EOF > /etc/apache2/sites-available/nextcloud.conf
<VirtualHost *:80>
ServerAdmin webmaster@localhost
DocumentRoot /var/www/nextcloud
Alias /nextcloud "/var/www/nextcloud/"
 
<Directory "/var/www/nextcloud/">
Options +FollowSymlinks
AllowOverride All
 
<IfModule mod_dav.c>
Dav off
</IfModule>
 
Require all granted
 
SetEnv HOME /var/www/nextcloud
SetEnv HTTP_HOME /var/www/nextcloud
</Directory>
 
ErrorLog ${APACHE_LOG_DIR}/nextcloud_error_log
CustomLog ${APACHE_LOG_DIR}/nextcloud_access_log common
</VirtualHost>
EOF

cat <<EOF > /tmp/sql-inject
CREATE DATABASE nextcloud;
CREATE USER 'nextcloud'@'localhost' IDENTIFIED BY 'YOUR_PASSWORD_HERE';
GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'localhost';
FLUSH PRIVILEGES;
EOF

mysql -u root -p < /tmp/sql-inject

cd /var/www
wget https://download.nextcloud.com/server/releases/nextcloud-18.0.5.zip
unzip nextcloud-18.0.5.zip
mkdir nextcloud/data
chown -R www-data:www-data nextcloud
a2ensite nextcloud.conf
a2dissite 000-default.conf
systemctl restart apache2
systemctl enable apache2 mariadb

clear
echo "Nextcloud installed, open the browser on https://[server-ip]/nextcloud"
echo "to continue the configuration"

}

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

clear
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

clear
echo "Doing git repositories installation on /opt"
sleep 3
if [ ! -d /opt/repositories ]
then mkdir -p /opt/repositories
fi

cd /opt/repositories
git clone https://github.com/tobi-wan-kenobi/bumblebee-status.git
git clone https://github.com/mauricioph/debian-afterinstall.git
git clone https://github.com/Airblader/i3 i3-gaps
git clone https://github.com/mauricioph/wallpaper.git
git clone https://github.com/mauricioph/myscripts.git
git clone https://github.com/mauricioph/i3-stuff.git
git clone https://github.com/mauricioph/mwm.git
for i in /opt/repositories/myscripts/*
do cp "${i}" /usr/local/bin/
chmod +x "/usr/local/bin/$(basename ${i})"
done
function packwall(){
chmod 0555 wallpaper/DEBIAN/postinst wallpaper/usr/local/bin/gwallpaper 
dpkg-deb --build wallpaper
dpkg --install wallpaper.deb
}

cp i3-stuff/systemd/wakelock.service /etc/systemd/system/
sudo systemctl enable wakelock.service 

function installdwm(){
cd /opt/repositories/mwm
make
make clean install
cd /opt/repositories/
}

function installi3(){
cd /opt/repositories/i3-gaps
autoreconf --force --install
rm -fr build
mkdir -p build && cd build/
../configure --prefix=/usr --sysconfdir=/etc --disable-sanitizers
make -j8
sudo make install
}

function swayout(){
cd /opt/repositories

mkdir sway-src
cd sway-src/
sudo apt update
sudo apt install build-essential cmake meson libwayland-dev wayland-protocols  libegl1-mesa-dev libgles2-mesa-dev libdrm-dev libgbm-dev libinput-dev  libxkbcommon-dev libudev-dev libpixman-1-dev libsystemd-dev libcap-dev  libxcb1-dev libxcb-composite0-dev libxcb-xfixes0-dev libxcb-xinput-dev  libxcb-image0-dev libxcb-render-util0-dev libx11-xcb-dev libxcb-icccm4-dev  freerdp2-dev libwinpr2-dev libpng-dev libavutil-dev libavcodec-dev  libavformat-dev universal-ctags -y

git clone https://github.com/swaywm/wlroots.git
cd wlroots/
git checkout 0.6.0
meson build
sudo ninja -C build install
sudo apt install autoconf libtool -y
cd ..

git clone https://github.com/json-c/json-c.git
cd json-c
git checkout json-c-0.13.1-20180305
sh autogen.sh
./configure --enable-threading --prefix=/usr/local CPUCOUNT=4
make -j 4
sudo make install
sudo ldconfig
cd ..

git clone https://git.sr.ht/~sircmpwn/scdoc
cd scdoc/
git checkout 1.9.4
make PREFIX=/usr/local -j 4
sudo make PREFIX=/usr/local install
sudo apt install libpcre3-dev libcairo2-dev libpango1.0-dev libgdk-pixbuf2.0-dev -y
cd ..

git clone https://github.com/swaywm/sway.git
cd sway/
git checkout 1.1.1
meson build
sudo ninja -C build install
cd ..

git clone https://github.com/swaywm/swaybg.git
cd swaybg/
git checkout 1.0 
meson build
sudo ninja -C build install
}

clear
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

clear
echo "To be future proof it is recomendable that you install sway (i3 for wayland), do you want to do it now?"
read swayornot
case "${swayornot}" in
	y) swayout ;;
	yes) swayout ;;
	*) echo "Skipping sway compilation" ;;
esac

clear
echo "We have 350+ wallpapers to be installed, do you want to install them?"
read pack
case ${pack} in
	y) packwall ;;
	yes) packwall ;;
	*) echo "No wallpaper installed"
esac
cd /opt/repositories

clear
echo "Should dwm be compiled now?"
read dwmnow
case ${dwmnow} in
        y)
        installdwm
        ;;
        yes)
        installdwm
        ;;
        *)
        echo "Skipping dwm compilation"
        ;;
esac

cd /opt/repositories

clear
echo "Should install nextcloud now?"
read nextcl
case ${nextcl} in
        y)
        nextcloud
        ;;
        yes)
        nextcloud
        ;;
        *)
        echo "Skipping dwm compilation"
        ;;
esac

clear
echo "All is installed, here are the programs recently installed"
sleep 5
dpkg-query -l 
