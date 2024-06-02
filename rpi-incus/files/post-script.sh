#!/bin/sh
#n0
# file: post-script.sh
# description: performs additional configuration necessary before 1st boot
#   takes an expanded ROOTFS dir as an argument. it is meant work with 
#   void-mklive's mkplatformfs.sh '-k' option
#a110w

# Add a new user
chroot "$1" sh -c "useradd void"


# Set hostname to the pi's serial number
cat >> "$1/etc/runit/core-services/005-hostname.sh" << EOF
sed 's/^0*/rpi-/' /sys/firmware/devicetree/base/serial-number > /etc/hostname
EOF

# Enable syslog (socklog)
chroot "$1" sh -c "ln -s /etc/sv/socklog-unix /etc/runit/runsvdir/default"
chroot "$1" sh -c "ln -s /etc/sv/nanoklogd /etc/runit/runsvdir/default"
chroot "$1" sh -c "usermod -aG socklog void"

# Enable dhcpcd, wpa_supplicant, ntpd, sshd as a service
#chroot "$1" sh -c "ln -s /etc/sv/dhcpcd /etc/runit/runsvdir/default"
#chroot "$1" sh -c "ln -s /etc/sv/ntpd /etc/runit/runsvdir/default"
#chroot "$1" sh -c "ln -s /etc/sv/sshd /etc/runit/runsvdir/default"
chroot "$1" sh -c "ln -s /etc/sv/wpa_supplicant /etc/runit/runsvdir/default"

# Enable incus
chroot "$1" sh -c "ln -s /etc/sv/incus /etc/runit/runsvdir/default"
chroot "$1" sh -c "ln -s /etc/sv/incus-user /etc/runit/runsvdir/default"
chroot "$1" sh -c "usermod -aG _incus-admin void"

# Replace sudo with doas
echo "ignorepkg=sudo" > "$1/usr/share/xbps.d/xbps-ignore.conf"
chroot "$1" sh -c "ln -sf /bin/doas /bin/sudo"
echo "permit nopass keepenv void" > "$1/etc/doas.conf"
chroot "$1" sh -c "xbps-remove -y sudo"

# Enable root ssh login
sed -i "$1/etc/ssh/sshd_config" -e 's|^#\(PermitRootLogin\) .*|\1 yes|g'

# Disable password authentication
#sed -i "$1/etc/ssh/sshd_config" -e 's|^#\(PasswordAuthentication\) .*|\1 no|g'

# Add ssh pubkeys to the user and root accounts
[ -d ../ssh_keys ] && {
	mkdir -p "$1/home/void/.ssh"
	cat ../ssh_keys/*.pub > "$1/home/void/.ssh/authorized_keys"
	mkdir -p "$1/root/.ssh"
	cat ../ssh_keys/*.pub > "$1/root/.ssh/authorized_keys"
}

# Configure wifi
cat ../conf/wifi.conf >> $1/etc/wpa_supplicant/wpa_supplicant.conf

