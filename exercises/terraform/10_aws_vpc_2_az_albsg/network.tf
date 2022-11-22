# Create VPC
resource "aws_vpc" "tf_vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Create Subnets
resource "aws_subnet" "tf_subnet_pub1" {
  vpc_id            = aws_vpc.tf_vpc.id
  cidr_block        = "10.0.0.0/20"
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "${var.project_name}-subnet-pub1"
    Type = "public"
  }
}

resource "aws_subnet" "tf_subnet_pub2" {
  vpc_id            = aws_vpc.tf_vpc.id
  cidr_block        = "10.0.16.0/20"
  availability_zone = var.availability_zones[1]

  tags = {
    Name = "${var.project_name}-subnet-pub2"
    Type = "public"
  }
}

resource "aws_subnet" "tf_subnet_priv1" {
  vpc_id            = aws_vpc.tf_vpc.id
  cidr_block        = "10.0.128.0/20"
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "${var.project_name}-subnet-priv1"
    Type = "private"
  }
}

resource "aws_subnet" "tf_subnet_priv2" {
  vpc_id            = aws_vpc.tf_vpc.id
  cidr_block        = "10.0.144.0/20"
  availability_zone = var.availability_zones[1]

  tags = {
    Name = "${var.project_name}-subnet-priv2"
    Type = "private"
  }
}

# Create IGW
resource "aws_internet_gateway" "tf_igw" {
  vpc_id = aws_vpc.tf_vpc.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Create NAT
resource "aws_eip" "tf_eip" {
  vpc = true
}

resource "aws_nat_gateway" "tf_nat_gw" {
  allocation_id = aws_eip.tf_eip.id
  subnet_id     = aws_subnet.tf_subnet_pub1.id

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [
    aws_internet_gateway.tf_igw
  ]

  tags = {
    Name = "${var.project_name}-nat-gw"
  }
}


# Create two route tables(pub and priv)
resource "aws_route_table" "tf_rt_pub" {
  vpc_id = aws_vpc.tf_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf_igw.id
  }

  tags = {
    Name = "${var.project_name}-rt-public"
    Type = "public"
  }
}

resource "aws_route_table" "tf_rt_priv" {
  vpc_id = aws_vpc.tf_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.tf_nat_gw.id
  }

  tags = {
    Name = "${var.project_name}-rt-private"
    Type = "private"
  }
}

# Create RTA
resource "aws_route_table_association" "tf_rta_sub_pub1" {
  subnet_id      = aws_subnet.tf_subnet_pub1.id
  route_table_id = aws_route_table.tf_rt_pub.id
}
resource "aws_route_table_association" "tf_rta_sub_pub2" {
  subnet_id      = aws_subnet.tf_subnet_pub2.id
  route_table_id = aws_route_table.tf_rt_pub.id
}
resource "aws_route_table_association" "tf_rta_sub_priv1" {
  subnet_id      = aws_subnet.tf_subnet_priv1.id
  route_table_id = aws_route_table.tf_rt_priv.id
}
resource "aws_route_table_association" "tf_rta_sub_priv2" {
  subnet_id      = aws_subnet.tf_subnet_priv2.id
  route_table_id = aws_route_table.tf_rt_priv.id
}