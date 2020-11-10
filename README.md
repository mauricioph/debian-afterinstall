# debian-afterinstall

This the script I use to deploy my Debian "profile" to as many computers I need.

Whenever I need to get the applications of my preference I just update the apt, install git, give the script execute privileges and run it.

In other words, just after install these are the commands I run:

```$ apt update
$ apt install git
$ cd /tmp
$ git clone https://github.com/mauricioph/debian-afterinstall.git
$ chmod +x debian-afterinstall
$ ./debian-afterinstall
```

This will install sudo and add a user to the group
Add to the sources.list the contrib and non-free repositories

The following apps will be installed:
Synaptic, file-roller, evince, clementine, vlc, gimp, shotwell, gparted, gnome-disk-utility, libreoffice, ufw, ffmpeg, audacity, pavucontrol, mixxx, ncmpdcpp, mpd, openssl, openvpn, samba, perl, phpmyadmin, sqlite3, rsync, testdisk, gdebi, ranger, restartd, smartmontools, fdupes and zbackup

Also some libraries to give these apps suport.

The firewall will block all ports, leaving only these services accessible:
SSH, Web server listening on 80,8080,8008,443
Samba and webmin

It will compile the mwm and i3 window manager with gaps enabled for X11 and Sway for Wayland.
