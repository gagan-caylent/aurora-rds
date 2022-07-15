output "aurora_cluster_arn" {
  description = "The ARN of the Primary Aurora cluster"
  value       = aws_rds_cluster.aurora_cluster.arn
}

output "aurora_cluster_id" {
  description = "The ID of the Primary Aurora cluster"
  value       = aws_rds_cluster.aurora_cluster.id
}

output "aurora_cluster_resource_id" {
  description = "The Cluster Resource ID of the Primary Aurora cluster"
  value       = aws_rds_cluster.aurora_cluster.cluster_resource_id
}

output "aurora_cluster_endpoint" {
  description = "Primary Aurora cluster endpoint"
  value       = aws_rds_cluster.aurora_cluster.endpoint
}

output "aurora_cluster_reader_endpoint" {
  description = "Primary Aurora cluster reader endpoint"
  value       = aws_rds_cluster.aurora_cluster.reader_endpoint
}

output "aurora_cluster_port" {
  description = "Primary Aurora cluster endpoint port"
  value       = aws_rds_cluster.aurora_cluster.port
}

output "aurora_cluster_database_name" {
  description = "Name for an automatically created database on Aurora cluster creation"
  value       = var.database_name
}

output "aurora_cluster_master_username" {
  description = "Auroras master username"
  value       = aws_rds_cluster.aurora_cluster.master_username
}

output "aurora_cluster_master_password" {
  description = "Aurora master User password"
  value       = aws_rds_cluster.aurora_cluster.master_password
  sensitive   = true
}

output "aurora_cluster_hosted_zone_id" {
  description = "Route53 hosted zone id of the Primary Aurora cluster"
  value       = aws_rds_cluster.aurora_cluster.hosted_zone_id
}

# aws_rds_cluster_instance
output "aurora_cluster_instance_endpoints" {
  description = "A list of all Primary Aurora cluster instance endpoints"
  value       = aws_rds_cluster_instance.primary.*.endpoint
}

output "aurora_cluster_instance_ids" {
  description = "A list of all Primary Aurora cluster instance ids"
  value       = aws_rds_cluster_instance.primary.*.id
}