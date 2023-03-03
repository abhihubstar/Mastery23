terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"
}
locals {
  addl_tags = {
      project = "Mastery23"
  }
  //Change this to your hosted zone name in aws account.
  hosted_zone_name = "chotelresort.com"
  app_name = "mastery23"
}


module "iam" {
  source = "./modules/iam"
  addl_tags = local.addl_tags
}

module "asg" {
  source = "./modules/asg"
  iam_instance_profile_name = module.iam.iam_instance_profile.name
  addl_tags = local.addl_tags
  domain = local.hosted_zone_name
  app_name = local.app_name
}

output "lb_url" {
  value = "http://${module.asg.dns_name}"
}

output "app_url" {
  value = "http://${module.asg.fqdn}"
}