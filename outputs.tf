output "security_group_id" {
  value = "${aws_security_group.instance.id}"
}

output "cluster_id" {
  value = "${aws_ecs_cluster.cluster.id}"
}
