packer {
  required_version = ">= 1.9.0"
  required_plugins {
    qemu = {
      version = "~> 1.0"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variable "ubuntu_version" {
  type    = string
  default = "24.04"
}

variable "output_directory" {
  type    = string
  default = "output"
}

source "qemu" "ubuntu" {
  source_path      = "ubuntu-${var.ubuntu_version}-server-cloudimg-amd64.img"
  output_directory = var.output_directory
  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"
  disk_size        = "8G"
  format           = "raw"  # Output raw .img format, not qcow2
  vm_name          = "ubuntu-${var.ubuntu_version}.img"
  
  ssh_username = "ubuntu"
  ssh_password = "ubuntu"
  ssh_timeout = "20m"
  
  boot_wait = "10s"
  boot_command = [
    "<enter><wait>",
  ]
}

build {
  sources = ["source.qemu.ubuntu"]

  provisioner "shell" {
    script = "scripts/install.sh"
  }

  provisioner "shell" {
    inline = [
      "sudo apt-get clean",
      "sudo rm -rf /var/lib/apt/lists/*",
      "sudo rm -rf /tmp/*"
    ]
  }
}
