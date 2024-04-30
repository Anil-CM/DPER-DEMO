variable "parent_apikey" {
  description = "The parent account api key"
  type        = string
}

variable "user_apikey" {
  description = "The invited user account api key"
  type        = string
}

variable "cluster_id" {
  description = "cluster id"
  type        = string
  default = "cnj769qf0pbnvjtep6f0"
}

variable "user_email" {
  description = "cluster id"
  type        = string
  default = "rajesh.pirati@ibm.com"
}
