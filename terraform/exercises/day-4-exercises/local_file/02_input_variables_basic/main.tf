terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.2.3"
    }
  }
}

resource "local_file" "tf_hello_file" {
  filename = var.filename
  content  = var.content
}