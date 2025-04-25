#!/bin/bash

echo "[+] Updating system..."
sudo xbps-install -Su -y

echo "[+] Installing DWM dependencies..."
sudo xbps-install -S make libX11-devel pkg-config libXft-devel libXinerama-devel glib-devel font-inconsolata-otf git gcc make xorg-server xinit xorg xauth  -y 

libX11-devel libXft-devel libXinerama-devel

echo "[+] Cloning suckless tools..."
mkdir -p ~/src
cd ~/src
git clone https://git.suckless.org/dwm
git clone https://git.suckless.org/dmenu
git clone https://git.suckless.org/st

echo "[+] Building and installing st..."
cd ~/src/st
cp config.def.h config.h
sudo make clean install

echo "[+] Building and installing dmenu..."
cd ~/src/dmenu
sudo make clean install

echo "[+] Building and installing dwm..."
cd ~/src/dwm
cp config.def.h config.h
sudo make clean install

echo "[+] Creating .xinitrc..."
echo 'exec dbus-launch --sh-syntax --exit-with-session dwm' > ~/.xinitrc

echo "[+] Done. You can now start DWM with the 'startx' command."
