// Reference: https://docs.aws.amazon.com/eks/latest/userguide/auto-configure-alb.html
resource "kubernetes_manifest" "alb_class_params" {
  manifest = {
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

resource "kubernetes_ingress_class_v1" "alb_class" {
  metadata {
    name = "alb"
    annotations = {
      // If an ingress doesn't specify a class, use this one.
      "ingressclass.kubernetes.io/is-default-class" = "true"
    }
  }
  spec {
    controller = "eks.amazonaws.com/alb"
    parameters {
      api_group = "eks.amazonaws.com"
      kind = "IngressClassParams"
      name = kubernetes_manifest.alb_class_params.manifest.metadata.name
    }
  }
}