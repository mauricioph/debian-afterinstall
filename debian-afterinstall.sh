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
#------------------------------------------------------------------------------#
#                   OFFICIAL UK DEBIAN REPOSITORY
#------------------------------------------------------------------------------#
# Edit these lines below based on the output from this page pointing your country repositories
# https://debgen.simplylinux.ch
#

###### Debian Main Repos
deb http://ftp.uk.debian.org/debian/ testing main contrib non-free
deb-src http://ftp.uk.debian.org/debian/ testing main contrib non-free

deb http://ftp.uk.debian.org/debian/ testing-updates main contrib non-free
deb-src http://ftp.uk.debian.org/debian/ testing-updates main contrib non-free

deb http://security.debian.org/ testing/updates main
deb-src http://security.debian.org/ testing/updates main

deb http://ftp.debian.org/debian buster-backports main contrib non-free
deb-src http://ftp.debian.org/debian buster-backports main contrib non-free

# End of the editable area

EOF

echo "Getting the signature of the repositories"

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

echo "Adding sudo"
apt install sudo
echo "Which user should be in sudo?"
read -s usuario
usermod -a -G sudo $usuario


echo "Preparing for docker"
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
cat <<EOF > /etc/apt/sources.list.d/docker.list
#curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
deb [arch=amd64] https://download.docker.com/linux/debian buster stable
EOF

echo "Preparing for google-chrome"
wget https://dl-ssl.google.com/linux/linux_signing_key.pub
apt-key add linux_signing_key.pub
rm linux_signing_key.pub
cat <<EOF > /etc/apt/sources.list.d/google.list
# wget https://dl-ssl.google.com/linux/linux_signing_key.pub
# sudo apt-key add linux_signing_key.pub
deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main
EOF

echo "Preparing for Skype"
wget https://go.skype.com/skypeforlinux-64.deb
dpkg -i skypeforlinux-64.deb
sleep 5 
rm skypeforlinux-64.deb

echo "Preparing for TOR"

cat <<EOF > /etc/apt/sources.list.d/tor.list
# curl https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --import
# gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add -
deb https://deb.torproject.org/torproject.org buster main
deb-src https://deb.torproject.org/torproject.org buster main
EOF

curl https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --import
gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | sudo apt-key add -

apt update
apt install tor deb.torproject.org-keyring


echo "Preparing for VSCode"

curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt-get install apt-transport-https
sudo apt-get update
sudo apt-get install code # or code-insiders
xdg-mime default code.desktop text/plain

echo "Installing systems apps"
apt install synaptic apt-xapian-index arandr asciinema atomicparsley  btrfs-progs build-essential busybox bzip2 bzip2-doc ca-certificates  ca-certificates-java ca-certificates-mono cabextract calf-plugins calibre calibre-bin gdebi yad apt-show-versions libio-pty-perl libauthen-pam-perl asciidoc xmlto uuid-dev libattr1-dev e2fsprogs f2fs-tools hfsutils jfsutils reiser4progs xfsprogs xfsdump lm-sensors upower zlib1g-dev libacl1-dev e2fslibs-dev libblkid-dev liblzo2-dev macfanctld unrar htop rofi feh compton unclutter nbtscan nmap i3lock zathura suckless-tools surf puddletag sonata lightdm-gtk-greeter lightdm-gtk-greeter-settings ccd2iso cdparanoia cdrdao certbot cgroupfs-mount light-locker -y

echo "Installing non-free system apps"
apt install amd64-microcode b43-fwcutter broadcom-sta-dkms default-jre smartmontools fdupes zbackup software-properties-common dirmngr ranger restartd firmware-linux-nonfree gparted ntfs* testdisk gdebi firmware-linux -y

echo "Installing base for i3-gaps"
apt install gcc make fancontrol read-edid i2c-tools conky-all fonts-font-awesome dh-autoreconf libxcb-keysyms1-dev libpango1.0-dev libxcb-util0-dev xcb libxcb1-dev libxcb-icccm4-dev libyajl-dev libev-dev libxcb-xkb-dev libxcb-cursor-dev libxkbcommon-dev libxcb-xinerama0-dev libxkbcommon-x11-dev libstartup-notification0-dev libxcb-randr0-dev libxcb-xrm0 libxcb-xrm-dev libxcb-shape0-dev

echo "Installing fonts"
apt install fontconfig fontconfig-config fonts-cantarell fonts-crosextra-caladea fonts-crosextra-carlito fonts-dejavu fonts-dejavu-core fonts-dejavu-extra fonts-droid-fallback fonts-font-awesome fonts-freefont-ttf fonts-glyphicons-halflings fonts-inter fonts-lato fonts-liberation fonts-liberation2 fonts-linuxlibertine fonts-lyx fonts-mathjax fonts-noto fonts-noto-cjk fonts-noto-cjk-extra fonts-noto-color-emoji fonts-noto-core fonts-noto-extra fonts-noto-hinted fonts-noto-mono fonts-noto-ui-core fonts-noto-ui-extra fonts-noto-unhinted fonts-opensymbol fonts-quicksand fonts-roboto-hinted fonts-roboto-unhinted fonts-sil-gentium fonts-sil-gentium-basic fonts-symbola fonts-urw-base35 fonts-wine ttf-bitstream-vera ttf-mscorefonts-installer tzdata -y

echo "Instaling miscelaneuos"
apt install chromium chromium-common chromium-lwn4chrome chromium-sandbox cinnamon-desktop-data cinnamon-l10n cmake cmake-data cmospwd code collectd-core colord colord-data comerr-dev:amd64 comprez compton conky conky-all conky-std console-setup console-setup-linux coreutils cups cups-browsed cups-bsd cups-client cups-common cups-core-drivers cups-daemon cups-filters cups-filters-core-drivers cups-ipp-utils cups-pk-helper cups-ppdc cups-server-common curl darkslide darktable dash davfs2 dos2unix dosfstools dunst dvdauthor e2fsprogs e2fsprogs-l10n easy-rsa easytag ebook-speaker efibootmgr eject exfat-utils exif exifprobe exiftags exiftran f2fs-tools facedetect fakeroot fatcat fdisk fdupes feh ffmpeg fgallery 

echo "Instaling miscelaneuos 2"

apt install firefox-esr firmware-amd-graphics firmware-b43-installer firmware-linux firmware-linux-free firmware-linux-nonfree firmware-misc-nonfree flac flactag flowblade foomatic-db-compressed-ppds foomatic-db-engine foremost forensics-extra four-in-a-row freepats freerdp2-dev freetype2-doc frei0r-plugins ftp funcoeszz fuse3 fwupd fwupd-amd64-signed ufw unar unattended-upgrades unrar unrar-free unzip update-glx

echo "Instaling miscelaneuos 3"

apt install gdebi gdebi-core gdisk geany geany-common geany-plugin-gproject geany-plugin-projectorganizer geany-plugins-common genisoimage gimp gimp-data gimp-data-extras git git-man gjacktransport glade glx-alternative-mesa gmic gnupg gnupg-agent gnupg-l10n gnupg-utils google-chrome-stable gparted gparted-common gperf gpg gpg-agent gpg-wks-client gpg-wks-server gpgconf gpgsm gpgv xscreensaver xscreensaver-data xserver-common xserver-xephyr xserver-xorg xserver-xorg-core xserver-xorg-input-all xserver-xorg-input-libinput xserver-xorg-input-wacom xserver-xorg-legacy xserver-xorg-video-all xserver-xorg-video-fbdev xserver-xorg-video-intel xserver-xorg-video-vesa  xterm xtightvncviewer xtrans-dev xxd xz-utils

echo "Instaling miscelaneuos 4"

apt install growisofs grub-common grub-efi grub-efi-amd64 grub-efi-amd64-bin grub-efi-amd64-dbg grub-efi-amd64-signed grub2-common gsfonts harvid hcxdumptool hddtemp hdparm heartbleeder hexcompare hexedit hfsutils hicolor-icon-theme hitori horst hostname hping3 hplip hplip-data htop httrack hunspell-en-gb hunspell-en-us hwdata hwinfo i965-va-driver:amd64 imagemagick imagemagick-6-common imagemagick-6.q16 zathura zathura-cb zathura-djvu zathura-pdf-poppler zathura-ps zbackup zeitgeist-core zenity zenity-common zip zlib1g  zlib1g-dev zpaq

echo "Instaling miscelaneuos 5"

apt install initramfs-tools initramfs-tools-core inkscape install-info installation-report intel-media-va-driver-non-free:amd64 intel-microcode intltool-debian jackd2 jackd2-firewire java-common javascript-common jdupes john john-data kbd keyboard-configuration keyutils krita krita-data

echo "Instaling miscelaneuos 6"

apt install lame laptop-detect lsb-base lsb-release lsdvd lshw lsof lua-bitop  lua-cjson  lua-expat  lua-json lua-lpeg  lua-socket  lua5.3 lvm2 lxappearance lxappearance-obconf lxc lxcfs lxde lxde-common lxde-core lxde-icon-theme lxde-settings-daemon lxhotkey-core lxhotkey-data lxhotkey-gtk lxhotkey-plugin-openbox lxinput lxlauncher lxlock lxmenu-data lxmusic lxpanel lxpanel-data lxpolkit lxrandr lxsession lxsession-data lxsession-default-apps lxsession-edit lxsession-logout lxtask lxterminal lynis lynx lynx-common lz4 lzop m4 macfanctld macutils mailutils mailutils-common make man-db manpages manpages-dev mariadb-client mariadb-common mcomix mdns-scan media-player-info mediainfo mediainfo-gui membernator memstat mencoder menu menu-xdg 

echo "Instaling miscelaneuos 7"

apt install mesa-utils mesa-va-drivers  meson mime-support min minissdpd minizip mixxx mixxx-data mkvtoolnix mkvtoolnix-gui moreutils mp3info mpack mpc mpd mpg123 mpg321 mplayer mplayer-gui mplayer-skin-blue mpv mscompress mtools nano nasm nbtscan ncmpcpp ncompress ncurses-base ncurses-bin ncurses-term ndiff nemo nemo-data nemo-fileroller nemo-gtkhash nemo-python net-tools netbase netcat-openbsd netcat-traditional netdiscover netpbm nfs-common nftables ngrep ninja-build nmap nmap-common node-highlight.js node-html5shiv node-jquery node-normalize.css nodejs nodejs-doc nomarch notification-daemon notify-osd nstreams ntfs-3g ntfs-3g-dev

echo "Instaling miscelaneuos 8"

apt install openssh-client openssh-server openssh-sftp-server openssl openvpn optipng os-prober osinfo-db oxygen-icon-theme pasystray patchage qjackctl qjackrcd qtractor refind reiser4progs reiserfsprogs samba samba-common samba-common-bin samba-dev  samba-dsdb-modules  samba-libs  samba-vfs-modules  sane-utils sbsigntool scour screenfetch scrot suckless-tools  sxiv synaptic sysstat tor torsocks 

echo "Installing php"
apt install php php-bz2 php-common php-curl php-gd php-google-recaptcha php-imagick php-json php-mbstring php-memcache php-mysql php-pear php-phpmyadmin-motranslator php-phpmyadmin-shapefile php-phpmyadmin-sql-parser php-phpseclib php-psr-cache php-psr-container php-psr-log php-sqlite3 php-symfony-cache php-symfony-cache-contracts php-symfony-expression-language php-symfony-service-contracts php-symfony-var-exporter php-tcpdf php-twig php-twig-extensions php-xml php-zip 

echo "Installing python"
apt install python3 python3-acme python3-alembic python3-amqp python3-anyjson python3-apparmor python3-appdirs python3-apscheduler python3-apsw python3-apt python3-argcomplete python3-argh python3-arrow python3-atomicwrites python3-attr python3-augeas python3-automat python3-automaton python3-babel python3-backcall python3-bcrypt python3-blinker python3-bluez python3-boto python3-bs4 python3-btrfs python3-cachetools python3-cairo  python3-ceilometerclient python3-certbot python3-certbot-apache python3-certifi python3-cffi-backend python3-chardet python3-cherrypy3 python3-chm python3-cinderclient python3-click python3-cliff python3-cmd2 python3-colorama python3-configargparse python3-configobj python3-confluent-kafka python3-constantly python3-croniter python3-crypto python3-cryptography python3-css-parser python3-cssselect python3-cssutils python3-cups python3-cupshelpers python3-cycler python3-dateutil python3-dbus python3-debconf python3-debian python3-debianbts python3-debtcollector python3-decorator python3-deprecation python3-dev python3-distlib python3-distro python3-distro-info python3-distutils python3-django python3-dnspython python3-docopt python3-docutils python3-dogpile.cache python3-ecdsa python3-editor python3-empy python3-entrypoints python3-eventlet python3-extras python3-fasteners python3-feedparser python3-filelock python3-fixtures python3-flask python3-future python3-futurist python3-gdal python3-genmsg python3-genpy python3-geoip python3-gi python3-gi-cairo python3-glanceclient python3-gnocchiclient python3-gpg python3-greenlet python3-hamcrest python3-html2text python3-html5-parser python3-html5lib python3-httplib2 python3-hyperlink python3-ibus-1.0 python3-icu python3-idna python3-ifaddr python3-impacket python3-importlib-metadata python3-incremental python3-ipython python3-ipython-genutils python3-ironicclient python3-iso8601 python3-itsdangerous python3-jedi python3-jeepney python3-jinja2 python3-jmespath python3-josepy python3-json-pointer python3-jsonpatch python3-jsonschema python3-jwt python3-kazoo python3-keyring python3-keyrings.alt python3-keystoneauth1 python3-keystoneclient python3-keystonemiddleware python3-kiwisolver python3-kombu python3-ldap3 python3-ldb python3-lib2to3 python3-libapparmor python3-libdiscid python3-libxml2  python3-linecache2 python3-logutils python3-lxml  python3-mako python3-markdown python3-markupsafe python3-matplotlib python3-mechanize python3-memcache python3-microversion-parse python3-migrate python3-mimeparse python3-minimal python3-mlt python3-monascaclient python3-monotonic python3-more-itertools python3-mpd python3-msgpack python3-munch python3-mutagen python3-mysqldb python3-netaddr python3-netifaces python3-networkx python3-neutronclient python3-novaclient python3-numpy python3-oauthlib python3-olefile python3-opencv python3-opencv-apps python3-openssl python3-openstackclient python3-openstacksdk python3-os-client-config python3-os-resource-classes python3-os-service-types python3-osc-lib python3-oslo.cache python3-oslo.concurrency python3-oslo.config python3-oslo.context python3-oslo.db python3-oslo.i18n python3-oslo.log python3-oslo.messaging python3-oslo.middleware python3-oslo.policy python3-oslo.reports python3-oslo.serialization python3-oslo.service python3-oslo.upgradecheck python3-oslo.utils python3-oslo.versionedobjects python3-packaging python3-pafy python3-parsedatetime python3-parsel python3-parso python3-paste python3-pastedeploy python3-pastescript python3-pathtools python3-pbr python3-pecan python3-pexpect python3-pickleshare python3-pil  python3-pip python3-pkg-resources python3-pluggy python3-prettytable python3-prompt-toolkit python3-psutil python3-psycopg2 python3-ptyprocess python3-py python3-pyasn1 python3-pyasn1-modules python3-pyatspi python3-pycadf python3-pycryptodome python3-pycurl python3-pydispatch python3-pydot python3-pygame python3-pygments python3-pygraphviz python3-pyinotify python3-pymysql python3-pyparsing python3-pyperclip python3-pyqt5 python3-pyqt5.qtsvg python3-pyqt5.qtwebchannel python3-pyqt5.qtwebengine python3-pyrsistent  python3-pysimplesoap python3-pytest python3-pyxattr python3-qrcode python3-queuelib python3-regex python3-rencode python3-renderpm  python3-reportbug python3-reportlab python3-reportlab-accel  python3-repoze.lru python3-requests python3-requests-toolbelt python3-requestsexceptions python3-rfc3339 python3-rfc3986 python3-roman python3-routes python3-samba python3-scipy python3-scour python3-scrapy python3-scrapy-djangoitem python3-secretstorage python3-service-identity python3-setproctitle  python3-setuptools python3-simplegeneric python3-simplejson python3-simplenote python3-singledispatch python3-sip python3-six python3-smbc python3-software-properties python3-soupsieve python3-sqlalchemy python3-sqlalchemy-ext python3-sqlparse python3-statsd python3-std-msgs python3-stevedore python3-tagpy python3-talloc  python3-taskflow python3-tdb python3-tempita python3-tenacity python3-testresources python3-testscenarios python3-testtools python3-textile python3-tk  python3-tk-dbg  python3-tornado python3-traceback2 python3-traitlets python3-twisted python3-twisted-bin  python3-tz python3-tzlocal python3-ujson python3-unittest2 python3-uno python3-urllib3 python3-vine python3-virtualenv python3-virtualenv-clone python3-virtualenvwrapper python3-vlc python3-w3lib python3-waitress python3-warlock python3-watchdog python3-watcher python3-watson python3-wcwidth python3-webencodings python3-webob python3-webtest python3-werkzeug python3-wget python3-wheel python3-whois python3-wrapt python3-wsme python3-xapian python3-xdg python3-yaml python3-yappi python3-zeroconf python3-zipp python3-zmq python3-zope.component python3-zope.event python3-zope.hookable python3-zope.interface python3.8 python3.8-dev python3.8-minimal

echo "Installing Internet of Things apps"
apt install rsync network-manager-gnome openssh-server openssl openvpn samba perl phpmyadmin sqlite3 ufw mtools -y

echo "Installing Office apps"
apt install libreoffice scrot feh ghostscript poppler-utils ffmpeg tesseract-ocr tesseract-ocr-eng clamav imagemagick ghostscript file-roller evince vlc v4l-utils v4l2loopback-dkms va-driver-all  vbetool vdpau-driver-all  vim-common vim-tiny vinagre vino virtualenv virtualenvwrapper vlc vlc-bin vlc-data vlc-l10n vlc-plugin-access-extra  vlc-plugin-base  vlc-plugin-fluidsynth  vlc-plugin-jack  vlc-plugin-notify  vlc-plugin-qt  vlc-plugin-samba  vlc-plugin-skins2  vlc-plugin-svg  vlc-plugin-video-output  vlc-plugin-video-splitter  vlc-plugin-visualization  vorbis-tools gimp shotwell gparted gnome-disk-utility libreoffice-writer libreoffice-calc libreoffice-impress -y

echo "Installing Media apps"
apt install blender blender-data blueman  bluetooth bluez bluez-obexd python-psutil python-netifaces python-power upower x11-xserver-utils mkvtoolnix-gui mplayer lsdvd libdvd-pkg aegisub dos2unix squashfs-tools obs-plugins obs-studio libavcodec-extra ffmpeg pavucontrol audacity jackd mixxx ncmpcpp -y

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
git clone https://github.com/mauricioph/dwm.git
for i in /opt/repositories/myscripts/*
do cp "${i}" /usr/local/bin/
chmod +x "/usr/local/bin/$(basename ${i})"
done
function packwall(){
chmod 0555 wallpaper/DEBIAN/postinst wallpaper/usr/local/bin/gwallpaper 
dpkg-deb --build wallpaper
dpkg --install wallpaper.deb
}
cp i3-stuff/lock-fusy.sh /usr/local/bin
chmod +x /usr/local/bin/lock-fusy.sh
cp i3-stuff/systemd/wakelock.service /etc/systemd/system/
sudo systemctl enable wakelock.service 

function installdwm(){
cd /opt/repositories/dwm
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

echo "To be future proof it is recomendable that you install sway (i3 for wayland), do you want to do it now?"
read swayornot
case "${swayornot}" in
	y) swayout ;;
	yes) swayout ;;
	*) echo "Skipping sway compilation" ;;
esac

echo "We have 350+ wallpapers to be installed, do you want to install them?"
read pack
case ${pack} in
	y) packwall ;;
	yes) packwall ;;
	*) echo "No wallpaper installed"
esac
cd /opt/repositories

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

echo "All is installed, here are the programs recently installed"
dpkg-query -l 
