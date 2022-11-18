terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.2.3"
    }
  }
}

resource "local_file" "tf_hello_file" {
  filename = "D:\\Programming\\TSOP\\on-this-day\\terraform\\day4\\exercises\\local_file\\results\\01_create_local_file.txt"
  content  = "Hello World"
}