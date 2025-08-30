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

source "qemu" "ubuntu" {
  iso_url              = var.image_url
  iso_checksum         = var.image_checksum

  disk_image           = true
  output_directory     = "output"
  
  # VM Configuration
  memory               = 2048
  cpus                 = 2
  disk_interface       = "virtio"
  net_device           = "virtio-net"
  disk_size            = "30G"
  format               = "qcow2"
  accelerator          = "kvm"
  headless             = true

  # Cloud-init configuration via CD-ROM
  cd_files = ["./http/user-data"]
  cd_label = "cidata"

  ssh_username         = "ubuntu"
  ssh_timeout          = "20m"
  shutdown_command     = "sudo shutdown -P now"
}

build {
  sources = ["source.qemu.ubuntu"]
  
  provisioner "shell" {
    inline = [
      "echo 'Waiting for cloud-init to complete...'",
      "cloud-init status --wait",
      "echo 'Cloud-init completed successfully'"
    ]
  }
  
  provisioner "shell" {
    inline = [
      "echo 'System information:'",
      "uname -a",
      "df -h",
      "free -h"
    ]
  }
}
