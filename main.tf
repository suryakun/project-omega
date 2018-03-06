provider "aws" {
  version = "~> 1.9.0"
  region = "${var.region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  max_retries = 3
}


# ---------------------------------------------------------------------------------------------------------------------
# SETUP ACCOUNT SETTINGS
# ---------------------------------------------------------------------------------------------------------------------

module "account_settings" {
  source = "./account_settings"
}

# ---------------------------------------------------------------------------------------------------------------------
# SETUP IAM
# ---------------------------------------------------------------------------------------------------------------------

module "iam" {
  source = "./iam"
}

# ---------------------------------------------------------------------------------------------------------------------
# VPC
# ---------------------------------------------------------------------------------------------------------------------

module "vpc" {
  source = "./vpc"
}

# ---------------------------------------------------------------------------------------------------------------------
# S3
# ---------------------------------------------------------------------------------------------------------------------

module "s3" {
  source = "./s3"
  domain = "project-omega-rbmrclo-1"
}

# ---------------------------------------------------------------------------------------------------------------------
# EC2
# ---------------------------------------------------------------------------------------------------------------------

module "ec2" {
  source = "./ec2"
  subnet_id = "${module.vpc.subnet_public_a_id}"
  security_group_ids = [
    "${module.vpc.vpc_default_security_group_id}",
    "${module.ec2.allow_all_security_group_id}",
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# RDS
# ---------------------------------------------------------------------------------------------------------------------

module "rds" {
  source = "./rds"
  subnet_ids = [
    "${module.vpc.subnet_private_a_id}",
    "${module.vpc.subnet_private_b_id}",
    "${module.vpc.subnet_private_c_id}",
  ]
  identifier = "project-omega-rds"
  name = "database1"

  # set dummy credentials for now
  username = "xxxxxxxxx"
  password = "xxxxxxxxx"
}

# ---------------------------------------------------------------------------------------------------------------------
# SNS
# ---------------------------------------------------------------------------------------------------------------------

module "sns" {
  source = "./sns"
}

# ---------------------------------------------------------------------------------------------------------------------
# Cloudwatch
# ---------------------------------------------------------------------------------------------------------------------

module "cloudwatch" {
  source = "./cloudwatch"
}

# ---------------------------------------------------------------------------------------------------------------------
# Autoscaling
# ---------------------------------------------------------------------------------------------------------------------

module "auto_scaling" {
  source = "./auto_scaling"

  security_group_ids = [
    "${module.vpc.vpc_default_security_group_id}",
    "${module.ec2.allow_all_security_group_id}",
  ]

  key_name      = "${module.ec2.key_name}"
  sns_topic_arn = "${module.sns.autoscaling_group_topic_arn}"
}
