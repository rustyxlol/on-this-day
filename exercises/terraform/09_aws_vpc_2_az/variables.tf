variable "region" {
    type=string
    default="ap-south-1"
}

variable "availability_zones" {
    type=list(string)
}

variable "amis" {
    type=map(string)
    default = {
        "ap-south-1" = "ami-074dc0a6f6c764218"
        "ap-northeast-1" = "ami-072bfb8ae2c884cc4"
    }
}
