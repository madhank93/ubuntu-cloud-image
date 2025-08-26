#!/bin/bash
set -euxo pipefail

echo "Waiting for apt-get lock to be released..."
while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1 ; do
    sleep 5
done

# The base cloud image already has the qemu-guest-agent.
# We just need to update, upgrade, and install our desired packages.
apt-get update
apt-get upgrade -y
apt-get install -y \
  net-tools \
  ubuntu-drivers-common \
  linux-generic

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
