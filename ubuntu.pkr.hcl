packer {
  required_plugins {
    qemu = {
      version = ">= 1.0.9"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variable "image_url" {
  type    = string
  default = "https://cloud-images.ubuntu.com/releases/24.04/release/ubuntu-24.04-server-cloudimg-amd64.img"
}

source "qemu" "ubuntu" {
  iso_url              = var.image_url
  iso_checksum         = "none"
  disk_image           = true

  output_directory     = "output"
  shutdown_command     = "sudo shutdown -P now"
  disk_interface       = "virtio"
  net_device           = "virtio-net"
  disk_size            = "30G"
  format               = "qcow2"
  accelerator          = "kvm"
  headless             = true
  
  cloud_init_cdrom     = true
  cloud_init = {
      user_data_file   = "./packer/cloud-init.yml"
      meta_data_file   = "./packer/meta-data"
  }
  
  ssh_username         = "ubuntu"
  ssh_timeout          = "30m"
}

build {
  sources = ["source.qemu.ubuntu"]

  # Run the main setup script
  provisioner "shell" {
    execute_command = "sudo -S -E sh -c '{{ .Command }}'"
    script          = "setup.sh"
  }

  # Final cleanup before creating the image
  provisioner "shell" {
    inline = [
      "echo 'Cleaning up image...'",
      "sudo rm -f /var/log/lastlog /var/log/alternatives.log /var/log/apt/history.log /var/log/apt/term.log",
      "sudo apt-get clean",
      "sudo cloud-init clean --logs --seed"
    ]
  }
}
