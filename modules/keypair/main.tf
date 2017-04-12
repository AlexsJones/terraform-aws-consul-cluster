variable "key_name" {}
variable "public_key" {}

resource "aws_key_pair" "terraform" {
  key_name   = "${var.key_name}"
  public_key = "${var.public_key}"
}

output "id" {
  value = "${aws_key_pair.terraform.id}"
}
