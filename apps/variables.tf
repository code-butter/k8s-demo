variable "app_image" {
  type = string
  description = "The container image for the app"
}

variable "pull_image" {
  type = bool
  description = "Always pull image even if in cache"
  default = true
}

variable "separate_nodes" {
  type = bool
  description = "Put deployment pods on separate nodes"
  default = true
}

variable "app_service_annotations" {
  type = map(string)
  description = "Annotations to put on app service"
  default = {}
}

variable "app_ingress_annotations" {
  type = map(string)
  description = "Annotations for the app ingress"
  default = {}
}

variable "app_host" {
  type = string
  description = "Host name for the demo app. Leave blank to preclude creating an ingress."
  default = null
}

variable "app_replicas" {
  type = number
  description = "Number of replicas to run for demo app"
  default = 3
}

variable "https_redirect_annotation" {
  type = string
  description = "Put in a HTTP redirect rule for ingress using this service on the annotation."
  default = null
}
