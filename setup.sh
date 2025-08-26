#!/bin/bash
set -euxo pipefail

echo "Waiting for apt-get lock..."
while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1 ; do
    sleep 5
done

# --- Standard Setup ---
# Update and install necessary packages
apt-get update
apt-get install -y \
  qemu-guest-agent \
  net-tools \
  ubuntu-drivers-common \
  linux-generic # Ensure latest kernel is installed

# Enable and start the qemu-guest-agent
systemctl enable qemu-guest-agent
systemctl start qemu-guest-agent

# Final upgrade
apt-get upgrade -y


# --- Key Replacement and Securing ---
# As the FINAL step, secure the image by replacing the temporary build key
# with your permanent access key.
echo "Replacing temporary build key with permanent access key..."

# This command overwrites the authorized_keys file, removing the temp key.
# !! IMPORTANT !!
# PASTE YOUR PERMANENT/PERSONAL PUBLIC SSH KEY BELOW
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHDtJdQ12Q8pUUGM16V1Ko+es5LzuGT/0FGWWTmsKQxj madhankumaravelu93@gmail.com" > /home/ubuntu/.ssh/authorized_keys

# Ensure the file has the correct ownership and permissions
chown ubuntu:ubuntu /home/ubuntu/.ssh/authorized_keys
chmod 600 /home/ubuntu/.ssh/authorized_keys

echo "Image is now secured and ready for use."
