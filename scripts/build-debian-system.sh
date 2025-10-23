#!/bin/bash

#lightdm / maybe sddm
#sxhkd
#bspc
#feh
#polybar
#fzf
#

#kitty
#rofi
#
# synergy
#
sudo apt install fonts-noto-color-emoji

## syncthing
sudo mkdir -p /etc/apt/keyrings
sudo curl -L -o /etc/apt/keyrings/syncthing-archive-keyring.gpg https://syncthing.net/release-key.gpg
echo "deb [signed-by=/etc/apt/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable-v2" | sudo tee /etc/apt/sources.list.d/syncthing.list
sudo apt-get update
sudo apt-get install syncthing


## Signal
wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg;
cat signal-desktop-keyring.gpg | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
wget -O signal-desktop.sources https://updates.signal.org/static/desktop/apt/signal-desktop.sources;
cat signal-desktop.sources | sudo tee /etc/apt/sources.list.d/signal-desktop.sources > /dev/null
sudo apt update
sudo apt install signal-desktop


## VM Stuff
sudo apt install -y \
    qemu-kvm \   			#hypervisor
    libvirt-daemon-system \ #management-daemon
    libvirt-clients \		#cli
    bridge-utils \			
    virt-manager \			#gui
    ovmf					#uefi support for VMs

sudo usermod -aG libvirt,kvm $USER

# 1) libvirt running?
sudo systemctl enable --now libvirtd virtlogd

sudo virsh net-start default
sudo virsh net-autostart default


sudo virsh net-list --all
virsh list --all
echo ">> Virtualization stack installed. Log out and back in to use libvirt without sudo."



## applets ##
#
#copyq
#flameshot
#blueman-applet
#udiskie
#nm-applet
#
#
#
#
#vimwiki
#bash configs
