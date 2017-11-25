
locals {
  ecs_cluster_name      = "${var.ecs_cluster_name}-${var.environment}-${var.service_name}"
  security_group_ecs    = "${var.security_group_ecs}-${var.environment}-${var.service_name}"
  key_pair              = "${var.key_pair}-${var.environment}-${var.service_name}"
  autoscaling_group     = "${var.autoscaling_group}-${var.environment}-${var.service_name}"
  launch_configuration_name_prefix = "${var.launch_configuration_name_prefix}-${var.environment}-${var.service_name}"
}

resource "aws_ecs_cluster" "cluster" {
  name = "${local.ecs_cluster_name}"
}

resource "aws_security_group" "instance" {
  name        = "${local.security_group_ecs}"
  description = "Container Instance Allowed Ports"
  vpc_id      = "${var.vpc_id}"

  # ingress {
  #   from_port   = 0
  #   to_port     = 65535
  #   protocol    = "tcp"
  #   cidr_blocks = "${var.allowed_cidr_blocks}"
  # }

  # ingress {
  #   from_port   = 0
  #   to_port     = 65535
  #   protocol    = "udp"
  #   cidr_blocks = "${var.allowed_cidr_blocks}"
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags          = {
    Name = "${local.security_group_ecs}"
    Environment = "${var.environment}"
    Date = "${timestamp()}"
    Version = "${var.version}"
  }
}

resource "aws_key_pair" "ecs_instance_key_pair" {
  key_name = "${local.key_pair}"
  public_key = "${file("${path.module}/templates/id_rsa.pub")}"
}

data "template_file" "user_data" {
  template = "${file("${path.module}/templates/user_data.sh")}"

  vars {
    cluster_name = "${local.ecs_cluster_name}"
  }
}

# Default disk size for Docker is 22 gig, see http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html
#
resource "aws_launch_configuration" "ecs" {
  name_prefix                 = "${local.launch_configuration_name_prefix}"
  image_id                    = "${lookup(var.amis, var.region)}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${aws_key_pair.ecs_instance_key_pair.key_name}"
  iam_instance_profile        = "${var.ecs_profile_id}"
  security_groups             = ["${aws_security_group.instance.id}", "${var.security_groups}"]
  associate_public_ip_address = "${var.associate_public_ip_address}"

  ebs_block_device {
    device_name           = "/dev/xvdcz"
    volume_size           = "${var.docker_storage_size}"
    volume_type           = "gp2"
    delete_on_termination = true
  }

  user_data            = "${data.template_file.user_data.rendered}"
  # aws_launch_configuration can not be modified.
  # Therefore we use create_before_destroy so that a new modified aws_launch_configuration can be created
  # before the old one get's destroyed. That's why we use name_prefix instead of name.
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "ecs" {
  name                 = "${local.autoscaling_group}"
  vpc_zone_identifier  = ["${var.subnets}"]
  launch_configuration = "${aws_launch_configuration.ecs.name}"
  min_size             = "${var.autoscale_min}"
  max_size             = "${var.autoscale_max}"
  desired_capacity     = "${var.autoscale_desired}"
  force_delete         = true
  # termination_policies (Optional) A list of policies to decide how the instances in the auto scale group should be terminated.
  # The allowed values are OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, Default.
  termination_policies = ["OldestLaunchConfiguration", "ClosestToNextInstanceHour", "Default"]

  tags = [{
    key                 = "Name"
    value               = "${local.autoscaling_group}"
    propagate_at_launch = true
  }]

  lifecycle {
    create_before_destroy = true
  }
}