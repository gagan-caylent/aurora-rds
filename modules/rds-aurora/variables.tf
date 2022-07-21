variable "region" {
  type        = string
  description = "The name of the primary AWS region you wish to deploy into"
}


variable "sec_region" {
  type        = string
  description = "The name of the secondary AWS region you wish to deploy into"
}


variable "identifier" {
  description = "Cluster identifier"
  type        = string
  default     = "aurora"
}

variable "name" {
  description = "Prefix for resource names"
  type        = string
  default     = "aurora"
}

variable "private_subnet_ids_p" {
  type        = list(string)
  description = "A list of private subnet IDs in your Primary AWS region VPC"
}


variable "private_subnet_ids_s" {
  type        = list(string)
  description = "A list of private subnet IDs in your Primary AWS region VPC"
}

variable "primary_instance_count" {
  description = "instance count for primary Aurora cluster"
  type        = number
  default     = 2
}

variable "secondary_instance_count" {
  description = "instance count for secondary Aurora cluster"
  type        = number
  default     = 1
}

variable "instance_class" {
  type        = string
  description = "Instance type to use at replica instance"
  default     = "db.r5.large"
}

variable "skip_final_snapshot" {
  type        = bool
  description = "skip creating a final snapshot before deleting the DB"
  #set the value to false for production workload
  default = true
}

variable "final_snapshot_identifier_prefix" {
  description = "The prefix name to use when creating a final snapshot on cluster destroy, appends a random 8 digits to name to ensure it's unique too."
  type        = string
  default     = "final"
}

variable "database_name" {
  description = "Name for an automatically created database on cluster creation"
  type        = string
  default     = "mydb"
}

variable "username" {
  description = "Master DB username"
  type        = string
  default     = "root"
}

# variable "password" {
#   description = "Master DB password"
#   type        = string
# }

variable "backup_retention_period" {
  description = "How long to keep backups for (in days)"
  type        = number
  default     = 7
}

variable "preferred_backup_window" {
  description = "When to perform DB backups"
  type        = string
  default     = "02:00-03:00"
}

variable "port" {
  description = "The port on which to accept connections"
  type        = string
  default     = "5432"
}

variable "auto_minor_version_upgrade" {
  description = "Determines whether minor engine upgrades will be performed automatically in the maintenance window"
  type        = bool
  default     = true
}

# variable "allow_major_version_upgrade" {
#   description = "Enable to allow major engine version upgrades when changing engine versions. Defaults to `false`"
#   type        = bool
#   default     = true
# }

variable "storage_encrypted" {
  description = "Specifies whether the underlying Aurora storage layer should be encrypted"
  type        = bool
  default     = false
}

variable "engine" {
  description = "Aurora database engine type: aurora (for MySQL 5.6-compatible Aurora), aurora-mysql (for MySQL 5.7-compatible Aurora), aurora-postgresql"
  type        = string
  default     = "aurora-postgresql"
}

variable "engine_version_pg" {
  description = "Aurora database engine version."
  type        = string
  default     = "13.6"
}

/*
variable "replica_scale_enabled" {
  description = "Whether to enable autoscaling for Aurora read replica auto scaling"
  type        = bool
  default     = false
}
*/

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default = {
    Name = "aurora-db"
  }
}

variable "monitoring_interval" {
  description = "Enhanced Monitoring interval in seconds"
  type        = number
  default     = 1
  validation {
    condition     = contains([0, 1, 5, 10, 15, 30, 60], var.monitoring_interval)
    error_message = "Valid values for var: monitoring_interval are (0, 1, 5, 10, 15, 30, 60)."
  }
}


variable "enable_postgresql_log" {
  description = "Enable PostgreSQL log export to Amazon Cloudwatch."
  type        = bool
  default     = true
}


# aws_appautoscaling_*
variable "autoscaling_enabled" {
  description = "Determines whether autoscaling of the cluster read replicas is enabled"
  type        = bool
  default     = false
}

variable "autoscaling_max_capacity" {
  description = "Maximum number of read replicas permitted when autoscaling is enabled"
  type        = number
  default     = 2
}

variable "autoscaling_min_capacity" {
  description = "Minimum number of read replicas permitted when autoscaling is enabled"
  type        = number
  default     = 1
}

variable "predefined_metric_type" {
  description = "The metric type to scale on. Valid values are `RDSReaderAverageCPUUtilization` and `RDSReaderAverageDatabaseConnections`"
  type        = string
  default     = "RDSReaderAverageCPUUtilization"
}

variable "autoscaling_scale_in_cooldown" {
  description = "Cooldown in seconds before allowing further scaling operations after a scale in"
  type        = number
  default     = 300
}

variable "autoscaling_scale_out_cooldown" {
  description = "Cooldown in seconds before allowing further scaling operations after a scale out"
  type        = number
  default     = 300
}

variable "autoscaling_target_cpu" {
  description = "CPU threshold which will initiate autoscaling"
  type        = number
  default     = 70
}

variable "autoscaling_target_connections" {
  description = "Average number of connections threshold which will initiate autoscaling. Default value is 70% of db.r4/r5/r6g.large's default max_connections"
  type        = number
  default     = 700
}


variable "vpc_id" {
  description = "ID of the VPC where to create security group"
  type        = string
  default     = ""
}


# aws_security_group
variable "create_security_group" {
  description = "Determines whether to create security group for RDS cluster"
  type        = bool
  default     = true
}


# variable "vault_name" {
#   description = "Name of the backup vault to create. If not given, AWS use default"
#   type        = string
#   default     = null
# }

# variable "plan_name" {
#   description = "The display name of a backup plan"
#   type        = string
# }

# variable "rules" {
#   description = "A list of rule maps"
#   type        = any
#   default     = []
# }