resource "aws_autoscaling_group" "consul-cluster-asg" {
  connection {
    user     = "ec2-user"
    key_file = "${module.keypair.public_key}"
  }

  name                 = "consul-asg"
  launch_configuration = "${aws_launch_configuration.consul-cluster.name}"
  min_size             = "${lookup(var.autoscaling_group_size,"min")}"
  max_size             = "${lookup(var.autoscaling_group_size,"max")}"
  load_balancers       = ["${aws_elb.consul-lb.name}"]

  vpc_zone_identifier = [
    "${aws_subnet.public-One.id}",
    "${aws_subnet.public-Two.id}",
  ]

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Project"
    value               = "consul-cluster"
    propagate_at_launch = true
  }
}
