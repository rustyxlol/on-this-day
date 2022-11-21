variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "availability_zones" {
  type    = list(string)
  default = ["ap-south-1a", "ap-south-1b"]
}

variable "project_name" {
  type = string
  default = "project_01"
}