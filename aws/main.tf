terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    helm = {
      source = "hashicorp/helm"
    }
    tailscale = {
      source  = "tailscale/tailscale"
      version = "0.20.0"
    }
  }
}

provider "tailscale" {
  oauth_client_id = var.tailscale_id
  oauth_client_secret = var.tailscale_secret
}

provider "aws" {
  region = var.aws_region
  allowed_account_ids = [var.aws_account_id]
  default_tags {
    tags = {
      Terraform = "true"
      Environment = "demo"
    }
  }
}

provider "kubernetes" {
  host = local.k8s_auth.host
  cluster_ca_certificate =  local.k8s_auth.ca_cert
  token                  =  local.k8s_auth.token
}

provider "helm" {
  kubernetes = {
    host = local.k8s_auth.host
    cluster_ca_certificate =  local.k8s_auth.ca_cert
    token                  =  local.k8s_auth.token
  }
}

locals {
  k8s_auth = {
    host = data.aws_eks_cluster.k8s_demo.endpoint,
    ca_cert = base64decode(data.aws_eks_cluster.k8s_demo.certificate_authority[0].data),
    token = data.aws_eks_cluster_auth.k8s_demo.token
  }
}

data "aws_eks_cluster" "k8s_demo" {
  name = module.eks.cluster_name
  depends_on = [ module.eks ]
}
data "aws_eks_cluster_auth" "k8s_demo" {
  name = module.eks.cluster_name
  depends_on = [ module.eks ]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  name    = "k8s-demo"
  cidr    = "10.0.0.0/16"
  azs     =  var.aws_azs
  public_subnets  =  [ for k,v in var.aws_azs: cidrsubnet(var.vpc_cidr, var.vpc_suffix_add, k)]
  private_subnets =  [ for k,v in var.aws_azs: cidrsubnet(var.vpc_cidr, var.vpc_suffix_add, var.vpc_private_add + k)]
  enable_nat_gateway = true
  single_nat_gateway = true
  create_igw = true
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"
  name = "k8s-demo"
  kubernetes_version = "1.33"
  compute_config = {
    enabled = true
  }
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  depends_on = [ aws_autoscaling_group.tailscale_node ]
}

# TODO: figure this out
# resource "aws_iam_role_policy_attachment" "eks" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
#   role       = module.eks.eks_managed_node_groups["default"].iam_role_name
# }



