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
  /* azs = ["us-west-2a", "us-west-2b", "us-west-2c", "us-west-2d"]  */
}

/* module "vpc" {
  source = "./modules/vpc"
  address_space = "10.0.0.0/16"
  subnets = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24","10.0.4.0/24" ]
  azs = local.azs
  addl_tags = local.addl_tags
} */

module "iam" {
  source = "./modules/iam"
  addl_tags = local.addl_tags
}

module "asg" {
  source = "./modules/asg"
  iam_instance_profile_name = module.iam.iam_instance_profile.name
  //vpc = module.vpc.id
  //subnet_ids = module.vpc.subnet_ids
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