// Reference: https://docs.aws.amazon.com/eks/latest/userguide/auto-configure-alb.html

locals {
  alb_class_params = {
    "apiVersion" = "eks.amazonaws.com/v1"
    "kind" = "IngressClassParams"
    "metadata" = {
      "name" = "alb"
    }
    "spec" = {
      "scheme" = "internet-facing"
    }
  }
}

// The kubernetes_manifest resource errors out unless a k8s endpoint is readily available, so we use this instead.
resource "kubectl_manifest" "alb_class_params" {
  yaml_body = yamlencode(local.alb_class_params)
}

resource "kubernetes_ingress_class_v1" "alb_class" {
  metadata {
    name = "alb"
    annotations = {
      "ingressclass.kubernetes.io/is-default-class" = "true"
    }
  }
  spec {
    controller = "eks.amazonaws.com/alb"
    parameters {
      api_group = "eks.amazonaws.com"
      kind = "IngressClassParams"
      name = local.alb_class_params.metadata.name
    }
  }

  depends_on = [kubectl_manifest.alb_class_params]
}