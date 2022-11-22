terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.23.0"
    }
  }
}

# For windows
provider "docker" {
  host = "npipe:////./pipe/docker_engine"
}

# Pull the image
resource "docker_image" "nginx" {
  name = "nginx:latest"
}

# Create a container
resource "docker_container" "nginx_container" {
  name  = "TF_Generated_NGINX"
  image = docker_image.nginx.image_id
  ports {
    internal = 80
    external = 8000
  }
}
