variable "vpc_id" {}
variable "gateway_name" {}
variable "gateway_project" {}

resource "aws_internet_gateway" "default" {
  vpc_id = "${var.vpc_id}"

  tags {
    Name    = "${var.gateway_name}"
    Project = "${var.gateway_project}"
  }
}

output "id" {
  value = "${aws_internet_gateway.default.id}"
}
