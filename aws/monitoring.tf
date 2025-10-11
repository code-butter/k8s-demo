# locals {
#   grafana_tags = {
#     app = "grafana"
#   }
# }
#
# resource "kubernetes_namespace" "monitoring" {
#   metadata {
#     name = "monitoring"
#   }
# }
#
# resource "kubernetes_deployment" "grafana" {
#
#   metadata {
#     name = "grafana"
#     namespace = kubernetes_namespace.monitoring.metadata[0].name
#   }
#
#   spec {
#     selector {
#       match_labels = local.grafana_tags
#     }
#     template {
#       metadata {
#         labels = local.grafana_tags
#       }
#       spec {
#         container {
#           image = "grafana/grafana:12.3.0-18392635519"
#           name = "grafana"
#           port {
#             container_port = 3000
#           }
#         }
#       }
#     }
#     replicas = 1
#   }
#
# }
#
# resource "kubernetes_service" "grafana" {
#   metadata {
#     name = "grafana"
#     namespace = kubernetes_namespace.monitoring.metadata[0].name
#   }
#
#   spec {
#     selector = local.grafana_tags
#     port {
#       name = "http"
#       port = 80
#       target_port = 3000
#     }
#     type = "LoadBalancer"
#   }
# }
#
# resource "helm_release" "kube_prometheus_stack" {
#   name       = "kube-prometheus-stack"
#   repository = "https://prometheus-community.github.io/helm-charts"
#   chart      = "kube-prometheus-stack"
#   namespace = kubernetes_namespace.monitoring.metadata[0].name
# }
#
#
