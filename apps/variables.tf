variable "app_image" {
  type = string
  description = "The container image for the app"
}

variable "pull_image" {
  type = bool
  description = "Always pull image even if in cache"
  default = true
}