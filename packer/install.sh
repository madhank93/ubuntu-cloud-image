#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive

# Update system
sudo apt-get update

# Install kernel headers and tools
sudo apt-get install -y linux-headers-generic linux-tools-generic

# Install eBPF packages
sudo apt-get install -y \
    libbpf1 \
    libbpf-dev \
    clang \
    llvm \
    bpftrace

# Install additional utilities
sudo apt-get install -y \
    wget \
    curl \
    qemu-guest-agent \
    net-tools \
    tree

# Configure BPF filesystem
echo "bpffs /sys/fs/bpf bpf defaults 0 0" | sudo tee -a /etc/fstab
sudo mkdir -p /sys/fs/bpf

# Verify installations
bpftool version || echo "bpftool not available"
clang --version
