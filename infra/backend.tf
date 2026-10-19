terraform {
  backend "s3" {
    bucket       = "resume-cicd-backend"
    key          = "resume/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}