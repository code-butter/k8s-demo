data "aws_route53_zone" "demo_zone" {
  name = var.route_53_zone
}

data "aws_iam_policy_document" "external_dns" {
  statement {
    effect = "Allow"
    actions = ["route53:ChangeResourceRecordSets"]
    resources = [data.aws_route53_zone.demo_zone.arn]
  }
  statement {
    effect = "Allow"
    actions = ["route53:ListH*"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "external_dns" {
  name = "dns-updates-k8s-demo"
  policy = data.aws_iam_policy_document.external_dns.json
}

module "iam_external_dns" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  create = true
  name = "example-external-dns"
  policies = {
    dns = aws_iam_policy.external_dns.arn
  }
  oidc_providers = {
    main = {
      provider_arn = module.eks.oidc_provider_arn
      namespace_service_accounts = [
        "kube-system:external-dns"
      ]
    }
  }
}

resource "kubernetes_service_account" "external_dns" {
  metadata {
    name = "external-dns"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.iam_external_dns.arn
    }
  }
}

resource "helm_release" "external_dns" {
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart = "external-dns"
  name  = "external-dns"
  namespace = "k8s-services"
  create_namespace = true
  values = [templatefile("${path.module}/external_dns.yml", {
    role_arn = module.iam_external_dns.arn
  })]
}