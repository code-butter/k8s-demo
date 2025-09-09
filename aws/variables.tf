variable "aws_account_id" {
  type = string
  description = "AWS account ID to make sure tf is not run against wrong environment"
}
variable "aws_region" {
  type = string
  description = "The region used for the project"
  default = "us-east-1"
}

variable "aws_azs" {
  type = list(string)
  description = "The AWS availability zones used for high availability subnets"
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "vpc_cidr" {
  type = string
  description = "The CIDR for the main virtual network."
  default = "10.0.0.0/16"
}

variable "vpc_suffix_add" {
  type = number
  description = "Number to add to CIDR suffix for main virtual network. Used to calculate subnets."
  default = 8
}

variable "vpc_private_add" {
  type = number
  description = "Number of subnets to skip for separation of public and private subnets."
  default = 128
}

variable "tailscale_id" {
  type = string
  sensitive = true
}

variable "tailscale_secret" {
  type = string
  sensitive = true
}