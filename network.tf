# VPC##########################################################################
resource "aws_vpc" "default" {
  cidr_block           = "${var.vpc_cidr_block}"
  enable_dns_hostnames = true

  tags {
    Name    = "Consul Cluster VPC"
    Project = "consul-cluster"
  }
}

# Gateway######################################################################
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name    = "Consul Cluster IGW"
    Project = "consul-cluster"
  }
}

# Public subnet 1##############################################################
resource "aws_subnet" "public-One" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "${var.public_cidr_block1}"
  map_public_ip_on_launch = true
  depends_on              = ["aws_internet_gateway.default"]
  availability_zone       = "${lookup(var.availability_zone,"primary")}"

  tags {
    Name    = "Consul Cluster Public Subnet"
    Project = "consul-cluster"
  }
}

resource "aws_route_table" "public-One-Route" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
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
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "${var.public_cidr_block2}"
  map_public_ip_on_launch = true
  depends_on              = ["aws_internet_gateway.default"]
  availability_zone       = "${lookup(var.availability_zone,"secondary")}"

  tags {
    Name    = "Consul Cluster Public Subnet"
    Project = "consul-cluster"
  }
}

resource "aws_route_table" "public-Two-Route" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
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
