// Create a main.tf file and configure your GCP provider, specifying your project ID and service account key file path:

provider "google" {
  project     = "my-project-id"
  credentials = file("path/to/service-account-key.json")
  region      = "us-central1"
}
