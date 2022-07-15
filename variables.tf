variable "region" {
  description = "The name of the primary AWS region you wish to deploy into"
  type        = string
  default     = "us-east-1"
}


variable "namespace" {
  description = "namespace, which could be your organiation name, e.g. amazon"
  type        = string
  default     = "aws"
}
variable "env" {
  description = "environment, e.g. 'sit', 'uat', 'prod' etc"
  type        = string
  default     = "dev"
}
variable "name" {
  description = "deployment name"
  type        = string
  default     = "aurora"
}
variable "delimiter" {
  description = "delimiter, which could be used between name, namespace and env"
  type        = string
  default     = "-"
}

variable "username" {
  description = "Master DB username"
  type        = string
  default     = "root"
}

#tfsec:ignore:general-secrets-no-plaintext-exposure
variable "password" {
  default     = ""
  type        = string
  description = "If no password is provided, a random password will be generated"
}

/*
variable "tags" {
  default     = {}
  description = "tags, which could be used for additional tags"
}
*/

variable "engine" {
  description = "Aurora database engine type: aurora, aurora-mysql, aurora-postgresql"
  type        = string
  default     = "aurora-postgresql"
  #default     = "aurora-mysql"
}

variable "engine_version_pg" {
  description = "Aurora PostgreSQL database engine version."
  type        = string
  default     = "13.6"
}


variable "monitoring_interval" {
  description = "Enhanced Monitoring interval in seconds"
  type        = number
  default     = 60
  validation {
    condition     = contains([0, 1, 5, 10, 15, 30, 60], var.monitoring_interval)
    error_message = "Valid values for var: monitoring_interval are (0, 1, 5, 10, 15, 30, 60)."
  }
}

# variable "snapshot_identifier" {
#   description = "id of snapshot to restore. If you do not want to restore a db, leave the default empty string."
#   type        = string
#   default     = ""
# }

variable "storage_encrypted" {
  description = "Specifies whether the underlying Aurora storage layer should be encrypted"
  type        = bool
  default     = true
}

variable "primary_instance_count" {
  description = "instance count for primary Aurora cluster"
  type        = number
  default     = 2
}


variable "private_subnet_ids_p" {
  type        = list(string)
  description = "A list of private subnet IDs in your Primary AWS region VPC"
  default = ["subnet-02de67bc25cfb7cc2" ,"subnet-0d9e13e6783b94ad0", "subnet-054fb2822fb7263ce"]
}
