if [ "$(id -u)" -eq 1000 ]; then
	printf "switch to the root user, and try again.\n"
	exit 1
fi

lsblk

read -p "Drive name? (/dev/vda): " DRIVE
read -p "NixOS configuration? (virtbox): " NIXOS_CONFIG
read -p "Reboot? (yes/no, default 'yes'): " REBOOT

umount -f /mnt/boot
umount -f /mnt
swapoff -a

nix-env -iA nixos.git

if [ -z "$DRIVE" ]; then
	DRIVE="/dev/vda"
fi

if [ -z "$NIXOS_CONFIG" ]; then
	NIXOS_CONFIG="virtbox"
fi

if [ -z "$REBOOT" ]; then
	REBOOT="yes"
fi

fdisk "$DRIVE" <<EOF
d

d

d

d

n
p
1

+200M
y
n
p
2

+8G
y
n
p
3


y
w
EOF

yes | mkfs.ext4 "$DRIVE"1
yes | mkswap "$DRIVE"2
yes | mkfs.ext4 "$DRIVE"3

mount "$DRIVE"3 /mnt
mkdir /mnt/boot
mount "$DRIVE"1 /mnt/boot
swapon "$DRIVE"2

nixos-generate-config --root /mnt
git clone https://git.beepboop.systems/rndusr/dot_testing /mnt/root/dot_testing
cp /mnt/etc/nixos/hardware-configuration.nix /mnt/root/dot_testing/
yes | nixos-install -I nixos-config=/mnt/root/dot_testing/$NIXOS_CONFIG.nix --cores 0
mv /mnt/root/dot_testing /mnt/home/usr/dot_testing

if [ "$REBOOT" = "yes" ]; then
	reboot
fi
