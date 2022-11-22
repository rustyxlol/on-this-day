terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.2.3"
    }
  }
}

resource "local_file" "pet" {
  filename = var.filename
  content  = "My favorite pet is: ${random_pet.my_pet.id}"
}

resource "random_pet" "my_pet" {
  prefix    = var.prefix[0]
  separator = var.separator
  length    = var.length
}

output pet-name {
  description="Returns pet id"
  value = random_pet.my_pet.id
}