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

/* data "google_service_account" "vmaccount" {
    account_id = "terraform-project-318114"
}

resource "google_service_account_key" "vmkey" {
  service_account_id = "${data.google_service_account.vmaccount.name}"
}

resource "local_file" "vmkeyfile" {
    content = "${google_service_account_key.vmkey.private_key}"
    filename = "/home/ubuntu/vmprivatekey"
}
*/ 
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
      ### Include this section to give the VM an external ip address
    }
  }
 
/* provisioner "file" {
  source = "first.txt"
  destination = "/home/ubuntu/first.txt"

  connection {
    type = "ssh"
    user = "ubuntu"
    ##private_key = "${var.public_key}" 
    private_key = "${file("./ubuntu6.ppk")}"
    host        = "${google_compute_instance.vm_instance.network_interface.0.access_config.0.nat_ip}"
  }
  }
*/
  
 ## create a test.txt in home directory once vm instance created successfully.
 ## metadata_startup_script = "echo 'this is test file' > /home/ubuntu/test.txt"
 ## metadata_startup_script = "sudo apt-get -y update; sudo apt-get -y dist-upgrade;sudo apt-get -y install nginx"
 ## metadata_startup_script = " cp /var/jenkins_home/workspace/terraform_demo/target/com.sonar.maven-0.0.3-SNAPSHOT.jar /home/ubuntu"
 
  ## Once vm instance created successfully do the following startup activities
  metadata_startup_script = "sudo apt-get update && sudo apt-get install apache2 -y && echo '<!doctype html><html><body><h1>Hello from Terraform on Google Cloud!</h1></body></html>' | sudo tee /var/www/html/index.html"
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

output "public_ip" {
  value = google_compute_instance.vm_instance.network_interface.0.access_config.0.nat_ip
}
