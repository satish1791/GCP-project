// Create a main.tf file and configure your GCP provider, specifying your project ID and service account key file path:

provider "google" {
  project     = "my-project-id"
  credentials = file("path/to/service-account-key.json")
  region      = "us-central1"
}

// Define a new VPC network in your main.tf file:

resource "google_compute_network" "vpc_network" {
  name                    = "my-vpc-network"
  auto_create_subnetworks = false
}

// Specify the IP range for the network:

resource "google_compute_network" "vpc_network" {
  name                    = "my-vpc-network"
  auto_create_subnetworks = false

  ip_cidr_range = "10.0.0.0/16"
}

//Step 4: Create a subnet

// Define a new subnet in your main.tf file:

resource "google_compute_subnetwork" "frontend-subnet" {
  name          = "frontend-subnet"
  ip_cidr_range = "10.0.1.0/24"
  network       = google_compute_network.vpc_network.self_link
}
// Specify the IP range for the subnet
// Associate the subnet with your VPC network


//Step 5: Create a load balancer
//Define a new load balancer in your main.tf file:


resource "google_compute_target_pool" "frontend-pool" {
  name        = "frontend-pool"
  region      = "us-central1"
  instances   = google_compute_instance_group.frontend-group.self_link
  health_checks = [
    google_compute_http_health_check.frontend-health-check.self_link
  ]
}

resource "google_compute_http_health_check" "frontend-health-check" {
  name               = "frontend-health-check"
  request_path       = "/"
  port               = "80"
  check_interval_sec = 10
  timeout_sec        = 5
}


// Specify the forwarding rules for the load balancer

// Associate the load balancer with your subnet


// Step 6: Create your compute resources

// Define a new instance group for your frontend servers:

resource "google_compute_instance_template" "frontend-template" {
  name = "frontend-template"
  machine_type = "n1-standard-1"
  disk {
    source_image = "debian-cloud/debian-10"
  }
  network_interface {
    network = google_compute_network.vpc_network.self_link
    subnetwork = google_compute_subnetwork.frontend-subnet.self_link
  }
  metadata {
    ssh-keys = "user:${file("~/.ssh/id_rsa.pub")}"
  }
  tags = ["frontend"]
}

resource "google_compute_instance_group" "frontend-group" {
  name = "frontend-group"
  zone = "us-central1-a"

  instance_template = google_compute_instance_template.frontend-template.self_link

  named_port {
    name = "http"
    port = 80
  }
}

  
// For backend instance template:

resource "google_compute_instance_template" "backend-template" {
  name_prefix = "backend-template-"
  machine_type = "n1-standard-2"
  disk_size_gb = 10

  disk {
    source_image = "debian-cloud/debian-10"
  }

  network_interface {
    network = google_compute_network.vpc_network.self_link
  }

  metadata_startup_script = "echo 'Backend server running'"

  tags = ["backend"]
}

// For database instance template:

resource "google_compute_instance_template" "database-template" {
  name_prefix = "database-template-"
  machine_type = "db-n1-standard-1"
  disk_size_gb = 100

  disk {
    auto_delete = true
    boot       = true
    initialize_params {
      source_image = "projects/cloud-ubuntu-os-cloud/global/images/family/ubuntu-1804-lts"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.self_link
  }

  metadata_startup_script = "echo 'Database server running'"

  tags = ["database"]
}

