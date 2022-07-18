output "aurora_cluster_arn" {
  description = "The ARN of the Primary Aurora cluster"
  value       = module.aurora.aurora_cluster_arn
}

output "aurora_cluster_id" {
  description = "The ID of the Primary Aurora cluster"
  value       = module.aurora.aurora_cluster_id
}

output "aurora_cluster_resource_id" {
  description = "The Cluster Resource ID of the Primary Aurora cluster"
  value       = module.aurora.aurora_cluster_resource_id
}

output "aurora_cluster_endpoint" {
  description = "Primary Aurora cluster endpoint"
  value       = module.aurora.aurora_cluster_endpoint
}

output "aurora_cluster_reader_endpoint" {
  description = "Primary Aurora cluster reader endpoint"
  value       = module.aurora.aurora_cluster_reader_endpoint
}

output "aurora_cluster_port" {
  description = "Primary Aurora cluster endpoint port"
  value       = module.aurora.aurora_cluster_port
}

output "aurora_cluster_database_name" {
  description = "Name for an automatically created database on Aurora cluster creation"
  value       = module.aurora.aurora_cluster_database_name
}

output "aurora_cluster_master_username" {
  description = "Auroras master username"
  value       = module.aurora.aurora_cluster_master_username
}

output "aurora_cluster_master_password" {
  description = "Aurora master User password"
  value       = module.aurora.aurora_cluster_master_password
  sensitive   = true
}

output "aurora_cluster_hosted_zone_id" {
  description = "Route53 hosted zone id of the Primary Aurora cluster"
  value       = module.aurora.aurora_cluster_hosted_zone_id
}

# aws_rds_cluster_instance
output "aurora_cluster_instance_endpoints" {
  description = "A list of all Primary Aurora cluster instance endpoints"
  value       = module.aurora.aurora_cluster_instance_endpoints
}

output "aurora_cluster_instance_ids" {
  description = "A list of all Primary Aurora cluster instance ids"
  value       = module.aurora.aurora_cluster_instance_ids
}