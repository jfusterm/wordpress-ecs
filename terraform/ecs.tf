resource "aws_ecs_cluster" "default" {
    name = "${var.ecs_cluster_name}"
}

resource "aws_ecs_task_definition" "wordpress" {
    family = "wp-ecs-task-tf"
    container_definitions = "${template_file.wp-container.rendered}"
}

resource "aws_ecs_service" "wp-ecs-svc" {
    name = "wp-ecs-svc-tf"
    cluster = "${aws_ecs_cluster.default.id}"
    task_definition = "${aws_ecs_task_definition.wordpress.arn}"
    desired_count = 1

    iam_role = "${aws_iam_role.qq-ecs-role.id}"

    load_balancer {
        elb_name = "${aws_elb.default.id}"
        container_name = "wordpress"
        container_port = 80
    }
  depends_on = ["aws_iam_role.qq-ecs-role","aws_instance.ecs-instance01"]
}

resource "aws_iam_role_policy" "qq-ecs-policy" {
    name = "qq-ecs-policy"
    role = "${aws_iam_role.qq-ecs-role.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:CreateCluster",
        "ecs:DeregisterContainerInstance",
        "ecs:DiscoverPollEndpoint",
        "ecs:Poll",
        "ecs:RegisterContainerInstance",
        "ecs:StartTelemetrySession",
        "ecs:Submit*",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:Describe*",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:Describe*",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer"
      ],
      "Resource": "*"
    }
  ]
}
EOF

  depends_on = ["aws_iam_role.qq-ecs-role"]
}

resource "aws_iam_role" "qq-ecs-role" {
  name = "qq-ecs-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
                    "ecs.amazonaws.com",
                    "ec2.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

