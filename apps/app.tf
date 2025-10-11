locals {
  app_labels = {
    app = "example"
  }
}
resource "kubernetes_deployment" "app" {
  metadata {
    name = "example-app"
  }
  timeouts {
    create = "3m"
    update = "3m"
    delete = "3m"
  }
  spec {
    replicas = "3"
    progress_deadline_seconds = 180

    selector {
      match_labels = local.app_labels
    }

    template {
      metadata {
        labels = local.app_labels
      }

      spec {
        // Keeps pods from being scheduled on the same node
        dynamic "affinity" {
          for_each = var.separate_nodes ? [1] : []
          content {
            pod_anti_affinity {
              required_during_scheduling_ignored_during_execution {
                topology_key = "kubernetes.io/hostname"
                label_selector {
                  match_expressions {
                    key = "app"
                    operator = "In"
                    values = [local.app_labels.app]
                  }
                }
              }
            }
          }
        }

        container {
          name = "server"
          image = var.app_image
          image_pull_policy = var.pull_image ? "Always" : "IfNotPresent"
          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

// This creates an NLB in AWS by default
resource "kubernetes_service" "app" {
  metadata {
    name = "demo-http"
    annotations = var.app_service_annotations
  }
  spec {
    selector = local.app_labels
    load_balancer_class = "eks.amazonaws.com/nlb"
    port {
      name = "http"
      port = 80
      target_port = "8080"
      protocol = "TCP"
    }
    type = "LoadBalancer"
  }
}

// This creates an ALB in AWS by default. Make sure your public subnets are tagged properly!
resource "kubernetes_ingress_v1" "app" {
  metadata {
    name = "example-app"
  }
  spec {
    rule {
      host = var.app_host
      http {
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.app.metadata[0].name
              port {
                number = kubernetes_service.app.spec[0].port[0].port
              }
            }
          }
        }
      }
    }
  }
}