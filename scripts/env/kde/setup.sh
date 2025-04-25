#!/bin/bash

echo -e "\033[33m[+] Updating system...\033[0m"
sudo xbps-install -Su -y

echo -e "\e[1;33m[+] Installing KDE minimal environment...\e[0m"

# Define packages minimal package
read -r -d '' PkgList <<'EOF'
kde-plasma
dolphin 
NetworkManager 
bluez 
blueman 
libspa-bluetooth 
pipewire wireplumber 
pavucontrol 
ffmpeg 
ffmpegthumbnailer 
kdegraphics-thumbnailers
dbus
EOF

sudo xbps-install -S $PkgList

echo "\033[33m[+] Enabling essential services...\033[0m"
sudo rfkill unblock bluetooth
sudo ln -sf /etc/sv/NetworkManager /var/service
sudo ln -sf /etc/sv/dbus /var/service
sudo ln -s /usr/share/applications/pipewire-pulse.desktop /etc/xdg/autostart/pipewire-pulse.desktop
sudo ln -sf /etc/sv/bluetoothd /var/service
sudo ln -sf /etc/sv/sddm /var/service
echo -e "\033[33m[!] Done.\033[0m"
