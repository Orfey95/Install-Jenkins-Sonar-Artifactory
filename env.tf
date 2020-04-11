provider "google" {
  credentials = "${file("top-script-272714-2bcdbfb8d2be.json")}"
  project = "top-script-272714"
  region = "europe-west3"
  zone = "europe-west3-a"
}

# JENKINS

resource "google_compute_address" "jenkins-static-ip-address" {
  name = "jenkins-static-ip-address"
}

resource "google_compute_instance" "vm_instance_jenkins" {
  name = "jenkins-instance"
  machine_type = "n1-standard-1"
  
  tags = ["jenkins"]
  
  boot_disk {
    initialize_params {
	  image = "ubuntu-os-cloud/ubuntu-1804-lts"
	}
  }

  metadata_startup_script = "sudo apt update"
  
  network_interface {
    network = "default"
    access_config {
	  nat_ip = "${google_compute_address.jenkins-static-ip-address.address}"
	}
  }
  
  metadata = {
    sshKeys = "Aleksandr:${file("id_rsa.pub")}"
  }
}

resource "google_compute_firewall" "jenkins-firewall" {
  name    = "jenkins-firewall"
  network = "default"
 
  allow {
    protocol = "tcp"
    ports    = ["8080","50000"]
  }
 
  allow {
    protocol = "icmp"
  }
  
  target_tags = ["jenkins"]
}

# SONAR

resource "google_compute_address" "sonar-static-ip-address" {
  name = "sonar-static-ip-address"
}

resource "google_compute_instance" "vm_instance_sonar" {
  name = "sonar-instance"
  machine_type = "n1-standard-2"
  
  tags = ["sonar"]
  
  boot_disk {
    initialize_params {
	  image = "centos-cloud/centos-7"
	}
  }
  
  network_interface {
    network = "default"
    access_config {
	  nat_ip = "${google_compute_address.sonar-static-ip-address.address}"
	}
  }
  
  metadata = {
    sshKeys = "Aleksandr:${file("id_rsa.pub")}"
  }
}

resource "google_compute_firewall" "sonar-firewall" {
  name    = "sonar-firewall"
  network = "default"
 
  allow {
    protocol = "tcp"
    ports    = ["9000"]
  }
 
  allow {
    protocol = "icmp"
  }
  
  target_tags = ["sonar"]
}

# ARTIFACTORY

resource "google_compute_address" "artifactory-static-ip-address" {
  name = "artifactory-static-ip-address"
}

resource "google_compute_instance" "vm_instance_artifactory" {
  name = "artifactory-instance"
  machine_type = "n1-standard-2"
  
  tags = ["artifactory"]
  
  boot_disk {
    initialize_params {
	  image = "centos-cloud/centos-7"
	}
  }
  
  network_interface {
    network = "default"
    access_config {
	  nat_ip = "${google_compute_address.artifactory-static-ip-address.address}"
	}
  }
  
  metadata = {
    sshKeys = "Aleksandr:${file("id_rsa.pub")}"
  }
}

resource "google_compute_firewall" "artifactory-firewall" {
  name    = "artifactory-firewall"
  network = "default"
 
  allow {
    protocol = "tcp"
    ports    = ["8081", "8082"]
  }
 
  allow {
    protocol = "icmp"
  }
  
  target_tags = ["artifactory"]
}
