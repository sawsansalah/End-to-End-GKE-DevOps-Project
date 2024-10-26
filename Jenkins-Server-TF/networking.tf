# VPC Network
resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
}

# Internet Routes
resource "google_compute_route" "route" {
  name             = var.route_name
  network          = google_compute_network.vpc.id
  dest_range       = "0.0.0.0/0"
  next_hop_gateway = "default-internet-gateway"
}

# Public Subnet
resource "google_compute_subnetwork" "public-subnet" {
  name          = var.subnet_name
  network       = google_compute_network.vpc.id
  ip_cidr_range = var.ip_cidr_range
  region        = var.region
}

# Firewall Rule
resource "google_compute_firewall" "firewall" {
  name     = "fw"
  network  = google_compute_network.vpc.id
  priority = 1000

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "8080", "9090", "9000"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_address" "static_ip" {
  name = "${var.instance_name}-static-ip"
  region = var.region
}