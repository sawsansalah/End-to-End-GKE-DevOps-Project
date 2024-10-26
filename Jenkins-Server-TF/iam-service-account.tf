resource "google_service_account" "jenkins_service_account" {
  account_id = "jenkins-service-account"
  display_name = "Jenkins Service Account"
}

resource "google_project_iam_member" "jenkins_service_account_owner" {
  project = var.project
  role    = "roles/owner"
  member  = "serviceAccount:${google_service_account.jenkins_service_account.email}"
}
