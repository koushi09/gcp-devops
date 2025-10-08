terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_compute_firewall" "allow_ssh_app_mysql" {
  name    = "allow-ssh-app-mysql"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["22", "8080", "3306"]
  }
  source_ranges = ["0.0.0.0/0"] # tighten later in production
}

resource "google_compute_instance" "app_vm" {
  name         = "springboot-vm"
  machine_type = "e2-micro"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts"
      size  = 30
      type  = "pd-standard"
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${var.ssh_public_key}"
    startup-script = <<-EOF
      #!/bin/bash
      apt-get update
      apt-get install -y docker.io
      # Run MySQL container (persistent data to /var/lib/mysql)
      docker run -d --name mysql-server -e MYSQL_ROOT_PASSWORD=change_me -e MYSQL_DATABASE=myappdb -p 3306:3306 -v /var/lib/mysql:/var/lib/mysql mysql:8
      # create deploy user dir
      mkdir -p /home/${var.ssh_user}/app
      chown -R ${var.ssh_user}:${var.ssh_user} /home/${var.ssh_user}/app
    EOF
  }

  network_interface {
    network = "default"
    access_config {} # gives external IP; needed to SSH from Github Actions
  }
}
output "vm_ip" {
  value = google_compute_instance.app_vm.network_interface[0].access_config[0].nat_ip
}