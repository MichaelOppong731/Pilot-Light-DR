data "terraform_remote_state" "primary" {
  backend = "s3"
  config = {
    bucket = "dr-primary-bucket-pilot-light"
    key    = "terraform.tfstate"
    region = "eu-west-1"
  }
}


terraform {
  backend "s3" {
    bucket       = "dr-secondary-bucket-pilot-light"
    key          = "terraform.tfstate"
    region       = "eu-west-1"
    encrypt      = true
    use_lockfile = true
  }
}