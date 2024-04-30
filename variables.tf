variable "parent" {
  type        = string
}

variable "user_apikey" {
  description = "The invited user account api key"
  type        = string
}

variable "vpc_name" {
  description = "vpc name "
  type        = string
  default = "dper-demo-vpc"
}

variable "user_email" {
  description = "cluster id"
  type        = string
  default = "rajesh.pirati@ibm.com"
}
