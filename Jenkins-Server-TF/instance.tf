# Compute Instance 
resource "google_compute_instance" "instance" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.image
      size  = var.disk_size
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.public-subnet.id
    access_config {
      nat_ip = google_compute_address.static_ip.address
    }
  }

  service_account {
    email = google_service_account.jenkins_service_account.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  metadata_startup_script = file("./tools-install.sh")

  metadata = {
    enable-oslogin = "TRUE"
  }
}
