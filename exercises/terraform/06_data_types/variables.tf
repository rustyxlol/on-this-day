variable "filename" {
  default = "./output/06_data_types.txt"
}
variable "content" {
  default = "The following are datatypes: "
}

variable "var_bool" {
  type    = bool
  default = "true"
}
variable "var_string" {
  type    = string
  default = "String!"
}
variable "var_number" {
  type    = number
  default = "1"
}
variable "var_list_string" {
  type    = list(string)
  default = ["list_item1", "list_item2", "list_item3"]
}

variable "var_list_number" {
  type    = list(number)
  default = ["1", "2", "10"]
}

variable "var_map" {
  type = map(string)
  default = {
    "key1" = "value1"
    "key2" = "value2"
  }
}

variable "var_object" {
  type = object({
    name  = string
    age   = number
    color = string
  })

  default = {
    name  = "bella"
    age   = "20"
    color = "red"
  }
}