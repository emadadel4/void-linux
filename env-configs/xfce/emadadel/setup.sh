#!/bin/bash

clear

echo -e "\033[1;33m[+] Updating system...\033[0m"
sudo xbps-install -Su
sudo xbps-install -S void-repo-nonfree void-repo-multilib-nonfree void-repo-multilib

read -r -d '' PkgList <<'EOF'
nano
xrandr
bluez
blueman
libspa-bluetooth
vlc
uget
redshift
redshift-gtk
kitty
bash-completion
freerdp
SDL2_ttf
unzip
unrar
git
mesa-dri-32bit
mesa-vulkan-intel 
mesa-vulkan-intel-32bit 
vulkan-loader-32bit 
intel-video-accel
gnutls-32bit 
libgcc-32bit 
libstdc++-32bit 
libdrm-32bit 
libglvnd-32bit
amberol
fish-shell
nodejs
mesa-intel-dri 
libva-intel-driver 
telegram-desktop
xfce4-screenshooter
EOF

echo -e "\033[1;33m[+] Installing base packages...\033[0m"
sudo xbps-install -S $PkgList

# Gaming packages
read -p $'\033[1;33m[i] Do you want Gaming on Void? (y/n): \033[0m' gaming_answer
if [[ "$gaming_answer" =~ ^[Yy]$ ]]; then
    sudo xbps-install -S wine wine-32bit winetricks lutris gamemode
fi

# Virtualization packages
read -p $'\033[1;33m[i] Do you want to install virt-manager? (y/n): \033[0m' virt_answer
if [[ "$virt_answer" =~ ^[Yy]$ ]]; then
    sudo xbps-install -S libvirt virt-manager virt-manager-tools qemu qemu-ga
fi

# Enable Bluetooth
echo -e "\033[1;33m[+] Enabling Bluetooth services...\033[0m"
sudo rfkill unblock bluetooth
sudo ln -sf /etc/sv/bluetoothd /var/service/

# GPU settings
echo -e "Setup GPU drivers settings"
echo "options i915 enable_dc=2 enable_fbc=1 fastboot=1 modeset=1" | sudo tee /etc/modprobe.d/intel-graphics.conf

# EFI fix
echo -e "\033[1;33m[+] Making Void GRUB bootable from fallback...\033[0m"
sudo mkdir -p /boot/efi/EFI/BOOT
sudo cp /boot/efi/EFI/void_grub/grubx64.efi /boot/efi/EFI/BOOT/BOOTX64.EFI

# Bash completion
echo -e "\033[1;33m[+] Add bash completion source line to .bashrc...\033[0m"
sudo echo "source /usr/share/bash-completion/bash_completion" >> .bashrc
source ~/.bashrc

echo -e "\033[1;33m[+] Installing fonts...\033[0m"
curl -L -o fonts.tar.gz https://github.com/emadadel4/void-linux/raw/refs/heads/main/env-configs/xfce/emadadel/fonts.tar.gz
sudo tar -xvf fonts.tar.gz -C /usr/share/fonts/ --strip-components=1
sudo fc-cache -f -v

echo -e "\033[1;33m[+] Restoring config files...\033[0m"
curl -L -o config.tar.gz https://github.com/emadadel4/void-linux/raw/refs/heads/main/env-configs/xfce/emadadel/config.tar.gz
tar -xvzf config.tar.gz

echo -e "\033[1;32m[✓] Setup completed successfully.\033[0m"

