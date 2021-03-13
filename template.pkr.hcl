variable "do_token" {
  default = env("PERSONAL_DO_TOKEN")
}

variable "base_system_image" {
  type    = string
  default = "ubuntu-20-04-x64"
}

variable "region" {
  type    = string
}

variable "size" {
  type    = string
}

variable "home" {
  default = env("HOME")
}

locals {
  timestamp = formatdate("DD-MM-YYYY", timestamp())
}

source "digitalocean" "ubuntu_20_04" {
  api_token     = "${var.do_token}"
  droplet_name  = "base-dev-image"
  image         = "${var.base_system_image}"
  region        = "${var.region}"
  size          = "${var.size}"
  snapshot_name = "base-dev-image.${local.timestamp}"
  ssh_username  = "root"
}

build {
  sources = [
    "source.digitalocean.ubuntu_20_04"]

  provisioner "shell" {
    inline = [
      "sleep 30",
      "apt-get update",
      "DEBIAN_FRONTEND=noninteractive apt-get install apt-transport-https htop -y",
      "sed -i 's/PasswordAuthentication no*/PasswordAuthentication yes/' /etc/ssh/sshd_config",
      "sed -i 's/#PubkeyAuthentication yes*/PubkeyAuthentication yes/' /etc/ssh/sshd_config",
      "systemctl restart sshd.service",
      "useradd --create-home --user-group --groups sudo --password $(openssl passwd -crypt root) --shell /bin/bash ansible",
      "useradd --create-home --user-group --groups sudo --password '' --shell /bin/bash romanow",
      "mkdir -p -m 0700 /home/romanow/.ssh",
      "passwd --expire romanow",
    ]
  }
  provisioner "file" {
    destination = "/home/romanow/.ssh/"
    source      = "${var.home}/.ssh/id_rsa.pub"
  }
  provisioner "shell" {
    inline = [
      "cd /home/romanow/.ssh",
      "cat id_rsa.pub >> authorized_keys",
      "chmod 0640 authorized_keys",
      "chown -R romanow:romanow /home/romanow/.ssh",
      "rm id_rsa.pub"
    ]
  }
}
