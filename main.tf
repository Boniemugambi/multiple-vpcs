provider "google" {
  project = "my-project11-377110"

    region  = "us-central1"
}

# create managementnet network and its subnet
resource "google_compute_network" "managementnet" {
  name = "managementnet"
}

resource "google_compute_subnetwork" "managementsubnet-us" {
  name          = "managementsubnet-us"
  ip_cidr_range = "5.130.0.0/20"
  network       = google_compute_network.managementnet.self_link
  region        = "us-central1"
}

# create privatenet network and its 2 subnets
resource "google_compute_network" "privatenet" {
  name = "privatenet"
}

resource "google_compute_subnetwork" "privatesubnet-us" {
  name          = "privatesubnet-us"
  ip_cidr_range = "172.16.0.0/24"
  network       = google_compute_network.privatenet.self_link
  region        = "us-central1"
}

resource "google_compute_subnetwork" "privatesubnet-eu1" {
  name          = "privatesubnet-eu"
  ip_cidr_range = "10.20.0.0/20"
  network       = google_compute_network.privatenet.self_link
  region        = "europe-west3"
}

# create a firewall-rule for the managementnet network
resource "google_compute_firewall" "managementnet-allow-icmp-ssh-rdp" {
  name    = "managementnet-allow-icmp-ssh-rdp"
  network = google_compute_network.managementnet.self_link
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["22", "3389"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["all-instances"]
}

# allow ssh
resource "google_compute_firewall" "managementnet-allow-ssh" {
  name    = "managementnet-allow-ssh"
  network = google_compute_network.managementnet.self_link
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  target_tags   = ["apply-to-all"]
  source_ranges = ["0.0.0.0/0"]

}

# create a firewall-rule for the privatenet network
resource "google_compute_firewall" "privatenet-allow-icmp-ssh-rdp" {
  name    = "privatenet-allow-icmp-ssh-rdp"
  network = google_compute_network.privatenet.self_link
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["22", "3389"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["all-instances"]
}

# create a vm instance inside the managementnetsubnet
resource "google_compute_instance" "managementsubnet-us-vm1" {
  name         = "managementnet-us-vm"
  machine_type = "n1-standard-1"
  zone         = "us-central1-c"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.managementsubnet-us.self_link
    access_config {}
  }
}

# create a vm instance inside the privatenetsubnet
resource "google_compute_instance" "privatenet-us-vm" {
  name         = "privatenet-us-vm"
  machine_type = "n1-standard-1"
  zone         = "us-central1-c"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.privatesubnet-us.self_link
    access_config {}
  }
}

#create the mynetwork network and subnet, just incase it is not created in the lab. 
resource "google_compute_network" "mynetwork" {
  name = "mynetwork"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "mynetwork1" {
  name          = "mynetwork1"
  ip_cidr_range = "10.10.0.0/24"
  network       = google_compute_network.mynetwork.self_link
  region        = "us-central1"
}

resource "google_compute_instance" "vm-appliance" {
  name         = "vm-appliance"
  machine_type = "n1-standard-4"
  zone         = "us-central1-c"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.managementsubnet-us.self_link
    access_config {}
  }
  network_interface {
    subnetwork = google_compute_subnetwork.privatesubnet-us.self_link
    access_config {}
  }
  network_interface {
    subnetwork = google_compute_subnetwork.mynetwork1.self_link
    access_config {}
  }

}

#