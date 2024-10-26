
terraform {

   backend "gcs" {
    bucket = "tf-state-26oct"
    prefix = "prod/kubernetes"
  }
}

variable "project_id" {
  description = "The project ID to host the cluster in"
}


module "prod_cluster" {
    source     = "./main"
    env_name   = "prod"
    project_id = "${var.project_id}"
}