terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.8.0"
    }
  }

  cloud {
    organization = "nvnguye4"

    workspaces {
      name = "terraform-nvnguye4-aws"
    }
  }
}