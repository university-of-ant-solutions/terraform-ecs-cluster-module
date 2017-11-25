# variable "allowed_cidr_blocks" {
#   default = ["0.0.0.0/0"]
# }

variable "associate_public_ip_address" {
  default = true
}

variable "autoscale_min" {
  default = "1"
  description = "Minimum autoscale (number of EC2)"
}

variable "autoscale_max" {
  default = "2"
  description = "Maximum autoscale (number of EC2)"
}

variable "autoscale_desired" {
  default = "1"
  description = "Desired autoscale (number of EC2)"
}

variable "docker_storage_size" {
  default = "22"
  description = "EBS Volume size in Gib that the ECS Instance uses for Docker images and metadata "
}

variable "instance_type" {
  default = "t2.nano"
}

variable "subnets" {
  type        = "list"
  description = "List of subnet ids to place the EC2 instance"
}

# http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html
variable "amis" {
  type = "map"
  description = "Which AMI to spawn. Defaults to the AWS ECS optimized images."
  default = {
    "us-east-2" = "ami-1c002379",
    "us-east-1" = "ami-9eb4b1e5",
    "us-west-2" = "ami-1d668865",
    "us-west-1" = "ami-4a2c192a",
    "eu-west-2" = "ami-cb1101af",
    "eu-west-1" = "ami-8fcc32f6",
    "eu-central-1" = "ami-0460cb6b",
    "ap-northeast-1" = "ami-b743bed1",
    "ap-southeast-2" = "ami-c1a6bda2",
    "ap-southeast-1" = "ami-ca3762a9", # *
    "ca-central-1" = "ami-b677c9d2"
  }
}

variable "security_group_ecs" {
  default = "security-group-as1"
  description = "The name of the security group for ECS cluster."
}

variable "key_pair" {
  default = "key-pair-as1"
  description = "The name of the key pair."
}

variable "autoscaling_group" {
  default = "autoscaling-group-as1"
  description = "The name of the autoscaling group for ECS cluster."
}

variable "launch_configuration_name_prefix" {
  default = "ec2-instance-as1"
}

variable "ecs_cluster_name" {
  default = "ecs-cluster-as1"
  description = "The name of the Amazon ECS cluster."
}

variable "service_name" {
  description = "The name of the service."
}

variable "vpc_id" {
  description = "The VPC id"
}

variable "security_groups" {
  type = "list"
}

variable "ecs_profile_id" {}

variable "region" {}

variable "environment" {}

variable "version" {}
