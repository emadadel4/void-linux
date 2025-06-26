#!/bin/bash

echo -e "\033[33m[+] Updating system...\033[0m"
sudo xbps-install -u xbps
sudo xbps-install -Su -y

echo -e "\e[1;33m[+] Installing XFCE minimal environment...\e[0m"

# Define packages minimal package
read -r -d '' PkgList <<'EOF'
xfce4 
xfce4-terminal 
lightdm 
lightdm-gtk-greeter
NetworkManager
pipewire
wireplumber 
pavucontrol 
xorg
xfce4-screenshooter
bluez
libspa-bluetooth
blueman
nano
firefox
gvfs
polkit
gvfs-afc 
gvfs-mtp 
gvfs-smb 
udisks2
xfce-polkit
dbus
EOF

sudo xbps-install -S $PkgList -y

echo "\033[33m[+] Enabling essential services...\033[0m"
sudo ln -sf /etc/sv/NetworkManager /var/service
sudo ln -sf /etc/sv/bluetoothd /var/service
sudo ln -s /usr/share/applications/pipewire-pulse.desktop /etc/xdg/autostart/pipewire-pulse.desktop
sudo ln -sf /etc/sv/lightdm /var/service/
sudo ln -sf /etc/sv/polkitd /var/service/
sudo ln -sf /etc/sv/udevd /var/service/
sudo ln -sf /etc/sv/dbus /var/service

echo -e "\033[33m[!] Done.\033[0m"
