#!/bin/sh
set -e
# Install base
apk update
apk add openrc
rc-update add devfs boot
rc-update add procfs boot
rc-update add sysfs boot
rc-update add networking default
rc-update add local default

# Install TTY
apk add agetty

# Setting up shell
apk add shadow
apk add bash bash-completion
chsh -s /bin/bash
# echo -e "luckfox\nluckfox" | passwd
echo "root:luckfox" | chpasswd
apk del -r shadow

# Install SSH
apk add openssh
ssh-keygen -A
rc-update add sshd default

# Extra stuff
apk add mtd-utils-ubi
# apk add bottom
# apk add neofetch

# NTP
apk add chrony
rc-update add chronyd default
apk add tzdata
cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
echo "Asia/Tokyo" > /etc/timezone
apk del tzdata

# Clear apk cache
rm -rf /var/cache/apk/*

# Packaging rootfs
for d in bin etc lib sbin usr; do tar c "$d" | tar x -C /extrootfs; done
for dir in dev proc root run sys oem userdata; do mkdir -p /extrootfs/${dir}; done
find /var -type d | while read d; do mkdir -p "/extrootfs$d"; done
find /var -type l | while read l; do cp -a "$l" "/extrootfs$l"; done
chmod 700 /extrootfs/var/empty
chmod 1777 /extrootfs/var/tmp

echo "=== extrootfs /var ==="
find /extrootfs/var -maxdepth 2 | sort
echo "=== ownership check ==="
ls -la /extrootfs/
