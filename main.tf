# Keypair #####################################################################
module "keypair" {
  source     = "./modules/keypair"
  key_name   = "terraform"
  public_key = "${file("keys/ami_keys.pub")}"
}

# VPC #########################################################################
module "vpc" {
  source         = "./modules/vpc"
  vpc_cidr_block = "${var.vpc_cidr_block}"

  vpc_name    = "consul-vpc"
  vpc_project = "Consul"
}

# Gateway######################################################################
module "gateway" {
  source = "./modules/gateway"
  vpc_id = "${module.vpc.id}"

  gateway_name    = "consul-gateway"
  gateway_project = "Consul"
}

# Public subnet 1##############################################################
resource "aws_subnet" "public-One" {
  vpc_id                  = "${module.vpc.id}"
  cidr_block              = "${var.public_cidr_block1}"
  map_public_ip_on_launch = true
  availability_zone       = "${lookup(var.availability_zone,"primary")}"

  tags {
    Name    = "Consul Cluster Public Subnet"
    Project = "consul-cluster"
  }
}

resource "aws_route_table" "public-One-Route" {
  vpc_id = "${module.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${module.gateway.id}"
  }

  tags {
    Name    = "Consul Cluster Public Route Table"
    Project = "consul-cluster"
  }
}

resource "aws_route_table_association" "public-Assoc-One" {
  subnet_id      = "${aws_subnet.public-One.id}"
  route_table_id = "${aws_route_table.public-One-Route.id}"
}

# Public subnet 2##############################################################
resource "aws_subnet" "public-Two" {
  vpc_id                  = "${module.vpc.id}"
  cidr_block              = "${var.public_cidr_block2}"
  map_public_ip_on_launch = true
  availability_zone       = "${lookup(var.availability_zone,"secondary")}"

  tags {
    Name    = "Consul Cluster Public Subnet"
    Project = "consul-cluster"
  }
}

resource "aws_route_table" "public-Two-Route" {
  vpc_id = "${module.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${module.gateway.id}"
  }

  tags {
    Name    = "Consul Cluster Public Route Table"
    Project = "consul-cluster"
  }
}

resource "aws_route_table_association" "public-Assoc-Two" {
  subnet_id      = "${aws_subnet.public-Two.id}"
  route_table_id = "${aws_route_table.public-Two-Route.id}"
}
