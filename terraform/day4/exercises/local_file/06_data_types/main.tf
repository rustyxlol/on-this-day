terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.2.3"
    }
  }
}

resource "local_file" "pet" {
  filename = var.filename
  content  = "${var.content}\nI'm a ${var.var_bool}\nI'm a ${var.var_string}\nI'm a number ${var.var_number}\nI'm a ${var.var_list_string[0]}\nI'm a list number ${var.var_list_number[1]}\nI'm a map entry with key1:${var.var_map["key1"]}\nI'm an object entry with name:${var.var_object["name"]}"
}