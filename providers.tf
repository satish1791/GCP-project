terraform {
  backend "gcs"{
      bucket = "webapp1"
      prefix = "three-tier-app"
  }
}
