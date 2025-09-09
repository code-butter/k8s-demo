locals {
  app_labels = {
    app = "example"
  }
}
resource "kubernetes_deployment" "app" {
  metadata {
    name = "example-app"
  }
  spec {
    replicas = "3"
    selector {
      match_labels = local.app_labels
    }
    template {
      metadata {
        labels = local.app_labels
        annotations = {
          configmap_hash = md5(jsonencode(kubernetes_config_map.app_redis.data))
        }
      }
      spec {
        container {
          name = "server"
          image = var.app_image
          image_pull_policy = var.pull_image ? "Always" : "IfNotPresent"
          port {
            container_port = 8080
          }
          env_from {
            config_map_ref {
              name = kubernetes_config_map.app_redis.metadata[0].name
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "app" {
  metadata {
    name = "demo-http"
  }
  spec {
    selector = local.app_labels
    port {
      name = "http"
      port = 8080
      target_port = "8080"
      protocol = "TCP"
    }
    type = "LoadBalancer"
  }
}