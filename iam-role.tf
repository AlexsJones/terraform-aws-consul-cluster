resource "aws_iam_policy" "leader-discovery" {
  name = "consul-node-leader-discovery"
  path = "/"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Stmt1468377974000",
            "Effect": "Allow",
            "Action": [
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeAutoScalingGroups",
                "ec2:DescribeInstances"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role" "consul-instance-role" {
  name = "consul-instance-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

//  Attach the policy to the role.
resource "aws_iam_policy_attachment" "consul-instance-leader-discovery" {
  name       = "consul-instance-leader-discovery"
  roles      = ["${aws_iam_role.consul-instance-role.name}"]
  policy_arn = "${aws_iam_policy.leader-discovery.arn}"
}

//  Create a instance profile for the role.
resource "aws_iam_instance_profile" "consul-instance-profile" {
  name  = "consul-instance-profile"
  roles = ["${aws_iam_role.consul-instance-role.name}"]
}
