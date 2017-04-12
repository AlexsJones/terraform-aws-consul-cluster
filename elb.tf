resource "aws_elb" "consul-lb" {
  name = "consul-lb-a"

  security_groups = ["${aws_security_group.web.id}",
    "${aws_security_group.consul-cluster-vpc.id}",
    "${aws_security_group.web.id}",
  ]

  subnets = ["${aws_subnet.public-One.id}",
    "${aws_subnet.public-Two.id}",
  ]

  listener {
    instance_port     = 8500
    instance_protocol = "http"
    lb_port           = 8500
    lb_protocol       = "http"
  }
}
