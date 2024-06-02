#!/bin/sh
#n0
# File: extract-void-linux-platformfs-to-memory-card.sh
# Description: partition, format and extract the void linux plaformfs to a
# 	       memory card (MicroSD or USB) for use with Raspberry Pis"
# Date: 2020-11-24 wfnintr
# Last Updated: 2021-05-31 wfnintr
#a110w

progname=$(basename $0)
usage(){
	echo "usage: "
	echo "  $progname <device> [platformfs.tar.xz]"
	echo ""
	echo "example:"
	echo "  $progname /dev/mmcblk0 void-rpi3-musl-PLATFORMFS-20210420.tar.xz"
	echo "  $progname /dev/sdb void-rpi3-musl-PLATFORMFS-20210420.tar.xz"
	exit 0
}

target=$1
local_source=$2
remote_source=https://alpha.de.repo.voidlinux.org/live/current/void-rpi3-musl-PLATFORMFS-20210218.tar.xz

[ -z "$target" ] && usage
case "$target" in 
	*mmcblk*)
		targetroot="$target"p2
		targetboot="$target"p1
		;;
	*sd*)
		targetroot="$target"2
		targetboot="$target"1
		;;
	*) echo "invalid target device given" && usage
		;;
esac

#echo $targetboot
#echo $targetroot
#exit 5

create_partitions(){
	[ ! -b $target ] && echo "You must provide the target memory card to partition. " && exit 1
	parted --script "$target" \
	mktable msdos \
	mkpart primary fat32 2048s 1024MB \
	toggle 1 boot \
	mkpart primary ext4 1025MB 100%
}

create_filesystems(){
	mkfs.vfat "$targetboot"
	mkfs.ext4 -O '^has_journal' "$targetroot"
}

mount_filesystems(){
	mkdir -p /mnt/rpi/rootfs
	mount "$targetroot" /mnt/rpi/rootfs
	mkdir /mnt/rpi/rootfs/boot
	mount "$targetboot" /mnt/rpi/rootfs/boot
}

extract_voidfs(){
        [ -z $local_source ] && {
#                wget "$remote_source" -qO - | tar xvfJp - -C /mnt/rpi/rootfs
		echo "no local source found"
        } || {
                tar xvfJp "$local_source" -C /mnt/rpi/rootfs # use local source
        }
        printf '%s /boot vfat defaults 0 0\n' $targetboot >> /mnt/rpi/rootfs/etc/fstab
}

unmount_filesystems(){
	umount /mnt/rpi/rootfs/boot && \
	umount /mnt/rpi/rootfs
}

create_partitions \
 && create_filesystems \
 && mount_filesystems \
 && extract_voidfs \
 && unmount_filesystems && echo 'done!'
