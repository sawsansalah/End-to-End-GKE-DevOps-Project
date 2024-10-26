terraform {
  required_version = ">=0.13.0"

  backend "gcs" {
    bucket  = "tf-state-26oct"
    prefix  = "terraform/state"
  }
}
