locals {
  redis_hosts = 6
  redis_replicas = 1
}

resource "kubernetes_secret" "redis_passwords" {
  type = "Opaque"
  metadata {
    name      = "redis-passwords"
    namespace = "default"
  }
  data = {
    default = "totallysecurepassword123"
  }
  lifecycle {
    ignore_changes = [data]
  }
}

data "kubernetes_secret" "redis_passwords" {
  metadata {
    name      = kubernetes_secret.redis_passwords.metadata[0].name
    namespace = kubernetes_secret.redis_passwords.metadata[0].namespace
  }
}

resource "kubernetes_config_map" "app_redis" {
  metadata {
    name = "app-redis"
  }
  data = {
    REDIS_ADDRS = "redis-demo-redis-cluster:6379"
    # Don't do this in production. Mount sensitive information as files instead.
    REDIS_PASSWORD = "totallysecurepassword123"
  }
}

