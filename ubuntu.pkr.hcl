packer {
  required_plugins {
    qemu = {
      version = ">= 1.1.4"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variable "image_url" {
  type    = string
  default = "https://cloud-images.ubuntu.com/releases/24.04/release/ubuntu-24.04-server-cloudimg-amd64.img"
}

variable "image_checksum" {
  type    = string
  default = "sha256:834af9cd766d1fd86eca156db7dff34c3713fbbc7f5507a3269be2a72d2d1820"
}

variable "ssh_password" {
  type    = string
  default = "supersecret"
}

variable "ssh_username" {
  type    = string
  default = "ubuntu"
}

source "qemu" "ubuntu" {
  iso_url              = var.image_url
  iso_checksum         = var.image_checksum

  disk_image           = true
  output_directory     = "output"

  disk_interface       = "virtio"
  net_device           = "virtio-net"

  disk_size            = "30G"
  format               = "raw"
  accelerator          = "kvm"
  headless             = true

  qemuargs = [
    ["-cdrom", "cidata.iso"]
  ]

  ssh_username         = var.ssh_username
  ssh_password         = var.ssh_password
  ssh_timeout          = "10m"
  shutdown_command     = "echo '${var.ssh_password}' | sudo -S shutdown -P now"
}

build {
  sources = ["source.qemu.ubuntu"]
  
  provisioner "shell" {
    inline = [
        "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for Cloud-Init...'; sleep 1; done" 
    ]
  }
}
