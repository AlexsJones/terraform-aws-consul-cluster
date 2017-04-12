resource "aws_launch_configuration" "consul-cluster" {
  key_name = "${aws_key_pair.terraform.id}"

  name_prefix          = "consul-node-"
  image_id             = "${lookup(var.amazon_amis,var.region)}"
  instance_type        = "t2.micro"
  security_groups      = ["${aws_security_group.consul-cluster-vpc.id}", "${aws_security_group.web.id}"]
  user_data            = "${data.template_file.consul.rendered}"
  iam_instance_profile = "${aws_iam_instance_profile.consul-instance-profile.id}"

  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "consul" {
  template = "${file("config/consul-config.sh")}"

  vars {
    asgname = "consul-asg"
    region  = "${var.region}"
    size    = "${lookup(var.autoscaling_group_size,"max")}"
  }
}
