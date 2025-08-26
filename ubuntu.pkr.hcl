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
  output_directory     = "output"
  shutdown_command     = "sudo -S shutdown -P now"
  disk_interface       = "virtio"
  net_device           = "virtio-net"
  disk_size            = "30G"
  format               = "qcow2"
  accelerator          = "kvm"
  headless             = true
  
  http_directory       = "http"
  boot_command = [
    "<enter><wait><enter><wait><f6><esc><wait>",
    "autoinstall ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ",
    "--- <enter>"
  ]

  boot_wait            = "5s"
  ssh_username         = "ubuntu"
  ssh_private_key_file = "./packer_key" # Use the temporary private key for connection
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
