#!/bin/bash
loadkeys fr
echo "BlackArch Auto-Install | Par Dravnor"

DISK="/dev/sda"

wipefs -a $DISK
parted -s $DISK mklabel gpt
parted -s $DISK mkpart ESP fat32 1MiB 513MiB
parted -s $DISK set 1 esp on
parted -s $DISK mkpart primary ext4 513MiB 100%

mkfs.vfat -F32 ${DISK}1
mkfs.ext4 ${DISK}2

mount ${DISK}2 /mnt
mkdir -p /mnt/boot/efi
mount ${DISK}1 /mnt/boot/efi

pacstrap /mnt base linux linux-firmware blackarch-keyring blackarch-installer sudo vim nano networkmanager grub efibootmgr xfce4 lightdm lightdm-gtk-greeter

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt /bin/bash <<EOF
ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
hwclock --systohc
echo "fr_FR.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=fr_FR.UTF-8" > /etc/locale.conf
echo "blackarch" > /etc/hostname

useradd -m -G wheel -s /bin/bash dravnor
echo "dravnor:toor" | chpasswd
echo "root:toor" | chpasswd
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

systemctl enable lightdm
systemctl enable NetworkManager

grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
EOF

echo "Installation terminée. Redémarre ton PC."
umount -R /mnt
