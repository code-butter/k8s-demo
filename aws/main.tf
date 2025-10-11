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
    # grafana = {
    #   source  = "grafana/grafana"
    #   version = "~> 3.25"
    # }
  }
}

# provider "grafana" {
#   url = "http://grafana-k8s-demo.${var.route_53_zone}"
#   auth = "testpassword1!"
# }


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
  cluster_name = "k8s-demo"
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
  cidr    =  var.vpc_cidr
  azs     =  var.aws_azs
  public_subnets  =  [ for k,v in var.aws_azs: cidrsubnet(var.vpc_cidr, var.vpc_suffix_add, k)]
  private_subnets =  [ for k,v in var.aws_azs: cidrsubnet(var.vpc_cidr, var.vpc_suffix_add, var.vpc_private_add + k)]

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
    "kubernetes.io/cluster/${local.cluster_name}": "owned"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"  = "1"
  }

  enable_dns_support = true
  enable_dns_hostnames = true
  enable_nat_gateway = true
  single_nat_gateway = true
  create_igw = true
}

data "http" "myip" {
  url = "https://ipv4.icanhazip.com"
}

// See configuration options here: https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"
  name = local.cluster_name
  kubernetes_version = "1.34"
  enable_cluster_creator_admin_permissions = true
  endpoint_public_access = true
  endpoint_private_access = true
  endpoint_public_access_cidrs = ["${chomp(data.http.myip.response_body)}/32"]

  compute_config = {
    enabled = true
    node_pools = ["general-purpose"]
  }

  iam_role_additional_policies = {
    ecr = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  }

  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
}

module "apps" {
  count = var.image_tag == "" ? 0 : 1
  source = "../apps"
  app_image = "${aws_ecr_repository.k8s_demo.repository_url}:${var.image_tag}"
  pull_image = false
  app_host = "k8s-demo.${var.route_53_zone}"
  app_service_annotations = {
    "external-dns.alpha.kubernetes.io/hostname": "k8s-demo.${var.route_53_zone}"
  }
  depends_on = [
    kubernetes_ingress_class_v1.alb_class
  ]
}
