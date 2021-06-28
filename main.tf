terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

provider "google" {

  credentials = "${file("./creds/serviceaccount.json")}"

  project = "terraform-project-318114"
  region  = "us-central1"
  zone    = "us-central1-c"
}

// Adding SSH Public Key Project Wide
resource "google_compute_project_metadata_item" "ssh-keys" {
  key   = "ssh-keys"
  value = "${var.public_key}"
}


resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}
resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance1"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
     ## image = "debian-cloud/debian-9"
      image = "ubuntu-2004-focal-v20210510"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
    }
  }
 
 ## create a test.txt in home directory once vm instance created successfully.
 ## metadata_startup_script = "echo 'this is test file' > /home/ubuntu/test.txt"
 metadata_startup_script = "sudo apt-get -y update; sudo apt-get -y dist-upgrade;sudo apt-get -y install nginx"

}

resource "google_compute_firewall" "default" {
  name    = "test-firewall"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22","80", "8080", "1000-2000"]
  }

  ## source_tags = ["web"]  -- filter purposes
}

output "ip" {
  value = google_compute_instance.vm_instance.network_interface.0.network_ip
}
