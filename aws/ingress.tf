data "aws_route53_zone" "demo_zone" {
  name = var.route_53_zone
}

data "aws_alb" "example_app" {
  tags = {
    "ingress.eks.amazonaws.com/stack" = "default/example-app" # namespace/app-name
  }
  depends_on = [
    module.apps
  ]
}

resource "aws_route53_record" "example_app" {
  name    = "k8s-demo"
  type    = "A"
  zone_id = data.aws_route53_zone.demo_zone.id
  alias {
    evaluate_target_health = false
    name                   = data.aws_alb.example_app.dns_name
    zone_id                = data.aws_alb.example_app.zone_id
  }
}


// Create and validate certificate
resource "aws_acm_certificate" "example_app" {
  domain_name = local.example_fqdn
  validation_method = "DNS"
}

resource "aws_route53_record" "example_app_validation" {
  for_each = {
    for dvo in aws_acm_certificate.example_app.domain_validation_options : dvo.domain_name => {
      name = dvo.resource_record_name
      record = dvo.resource_record_value
      type = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  zone_id = data.aws_route53_zone.demo_zone.id
  name = each.value.name
  type = each.value.type
  ttl = 300
  records = [each.value.record]
}

resource "aws_acm_certificate_validation" "example_app" {
  certificate_arn = aws_acm_certificate.example_app.arn
  validation_record_fqdns = [for record in aws_route53_record.example_app_validation : record.fqdn]
  depends_on = [aws_route53_record.example_app_validation]
}

# "External DNS" is a K8s controller that sets up DNS records in cloud providers. I couldn't get it working, but this
# gets you part way through. The code above sets up the DNS record in a more manual way.
#
# data "aws_iam_policy_document" "external_dns" {
#   statement {
#     effect = "Allow"
#     actions = ["route53:ChangeResourceRecordSets"]
#     resources = [data.aws_route53_zone.demo_zone.arn]
#   }
#   statement {
#     effect = "Allow"
#     actions = ["route53:ListH*"]
#     resources = ["*"]
#   }
# }
#
# resource "aws_iam_policy" "external_dns" {
#   name = "dns-updates-k8s-demo"
#   policy = data.aws_iam_policy_document.external_dns.json
# }
#
# module "iam_external_dns" {
#   source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
#   create = true
#   name = "example-external-dns"
#   policies = {
#     dns = aws_iam_policy.external_dns.arn
#   }
#   oidc_providers = {
#     main = {
#       provider_arn = module.eks.oidc_provider_arn
#       namespace_service_accounts = [
#         "kube-system:external-dns"
#       ]
#     }
#   }
# }
#
# resource "kubernetes_service_account" "external_dns" {
#   metadata {
#     name = "external-dns"
#     annotations = {
#       "eks.amazonaws.com/role-arn" = module.iam_external_dns.arn
#     }
#   }
# }
#
# resource "helm_release" "external_dns" {
#   repository = "https://kubernetes-sigs.github.io/external-dns/"
#   chart = "external-dns"
#   name  = "external-dns"
#   namespace = "k8s-services"
#   create_namespace = true
#   values = [templatefile("${path.module}/external_dns.yml", {
#     role_arn = module.iam_external_dns.arn
#   })]
# }