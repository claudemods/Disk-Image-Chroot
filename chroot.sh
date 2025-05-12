#!/bin/bash

# Get image path
read -e -p "Enter path to .img file: " IMAGE_PATH

# Verify image exists
sudo [ ! -f "$IMAGE_PATH" ] && echo "Error: Image file not found!" >&2 && exit 1

# Mount setup
MOUNT_DIR=$(sudo mktemp -d)
LOOP_DEV=$(sudo losetup -f -P --show "$IMAGE_PATH")

# Mount root partition (p2)
sudo mount "${LOOP_DEV}p2" "$MOUNT_DIR"

# Mount boot partition (p1) to /boot
sudo mount "${LOOP_DEV}p1" "$MOUNT_DIR/boot"

# Mount essentials
sudo mount -t proc /proc "$MOUNT_DIR/proc"
sudo mount -t sysfs /sys "$MOUNT_DIR/sys"
sudo mount --bind /dev "$MOUNT_DIR/dev"
sudo mount --bind /dev/pts "$MOUNT_DIR/dev/pts"
sudo mount -t tmpfs tmpfs "$MOUNT_DIR/run"

# Chroot in
sudo chroot "$MOUNT_DIR"

# Cleanup
sudo umount "$MOUNT_DIR/run"
sudo umount "$MOUNT_DIR/dev/pts"
sudo umount "$MOUNT_DIR/dev"
sudo umount "$MOUNT_DIR/sys"
sudo umount "$MOUNT_DIR/proc"
sudo umount "$MOUNT_DIR/boot"  # Unmount boot first
sudo umount "$MOUNT_DIR"
sudo losetup -d "$LOOP_DEV"
sudo rmdir "$MOUNT_DIR"
