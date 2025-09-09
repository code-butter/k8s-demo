resource "helm_release" "redis" {
  chart      = "redis-cluster"
  repository = "oci://registry-1.docker.io/bitnamicharts"
  name       = "redis-demo"
  namespace  = "default"
  timeout    = 600

  values = [
    yamlencode({
      existingSecret            = kubernetes_secret.redis_passwords.metadata[0].name
      existingSecretPasswordKey = "default"
      cluster = {
        nodes    = local.redis_hosts
        replicas = local.redis_replicas
      }
      persistence = {
        size = "1Gi"
      }
      # tls = {
      # }
      # redis = {
      #   resources = {
      #     // Resource limits
      #   }
      #   extraVolumes = [
      #     // Can add a volume for ACL users
      #   ]
      #   extraVolumeMounts = [
      #     // Mount the volume for ACL users here
      #   ]
      #   configmap = ""
      # }
    })
  ]
}