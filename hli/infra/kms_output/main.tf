data "terraform_remote_state" "kms" {
  backend = "s3"

  config = {
    bucket = "terraform-pvcom-poc-tfstate"
    key    = "tfstate/lakeformation/hli/infra/kms/env/development/terraform.tfstate"
    region = "ap-southeast-1"
    assume_role = {
      role_arn = "arn:aws:iam::302010997939:role/tfstate-pvcom-state-access"
    }
  }
}

