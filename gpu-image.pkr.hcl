packer {
  required_plugins {
    digitalocean = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/digitalocean"
    }
  }
}

variable "do_token" {
  type      = string
  sensitive = true
}

source "digitalocean" "gpu_image" {
  api_token = var.do_token
  image     = "ubuntu-22-04-x64"
  region    = "blr1"             # choose closest region
  size      = "g-2vcpu-8gb"      # GPU droplet type
  snapshot_name = "gpu-ubuntu-22.04-{{timestamp}}"
  ssh_username  = "root"
}

build {
  sources = ["source.digitalocean.gpu_image"]

  provisioner "shell" {
    inline = [
      "echo 'Updating system...'",
      "apt-get update -y",
      "DEBIAN_FRONTEND=noninteractive apt-get upgrade -y",
      "",
      "echo 'Installing base tools...'",
      "apt-get install -y curl wget git docker.io",
      "systemctl enable docker",
      "usermod -aG docker root",
      "",
      "echo 'Installing NVIDIA drivers and CUDA toolkit...'",
      "add-apt-repository ppa:graphics-drivers/ppa -y",
      "apt-get update -y",
      "apt-get install -y nvidia-driver-535",
      "reboot || true",
      "",
      "echo 'Installing NVIDIA Container Toolkit...'",
      "distribution=$(. /etc/os-release;echo $ID$VERSION_ID)",
      "curl -s -L https://nvidia.github.io/libnvidia-container/gpgkey | apt-key add -",
      "curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | tee /etc/apt/sources.list.d/nvidia-container-toolkit.list",
      "apt-get update -y",
      "apt-get install -y nvidia-container-toolkit",
      "systemctl restart docker",
      "",
      "echo 'GPU image ready ✅'"
    ]
  }
}
