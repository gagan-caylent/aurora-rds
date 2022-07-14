
###########
# Defaults
###########

provider "aws" {
  alias  = "primary"
  region = var.region
}

# provider "aws" {
#   alias  = "secondary"
#   region = var.sec_region
# }

#########################
# Collect data
#########################

data "aws_availability_zones" "region_p" {
  state    = "available"
  provider = aws.primary
}

# data "aws_availability_zones" "region_s" {
#   state    = "available"
#   provider = aws.secondary
# }


###########
# IAM
###########


data "aws_iam_policy_document" "monitoring_rds_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}


resource "aws_iam_role" "rds_enhanced_monitoring" {
  description         = "IAM Role for RDS Enhanced monitoring"
  path                = "/"
  assume_role_policy  = data.aws_iam_policy_document.monitoring_rds_assume_role.json
  managed_policy_arns = ["arn:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"]
  tags                = var.tags
}


########
# AURORA
########


resource "aws_rds_cluster" "aurora_cluster" {
  #provider                         = aws.primary
  #global_cluster_identifier        = var.setup_globaldb ? aws_rds_global_cluster.globaldb[0].id : null
  cluster_identifier               = "${var.identifier}-${var.region}"
  engine                           = var.engine #"aurora-postgresql"
  #engine_version                   = var.engine_version_pg
  #allow_major_version_upgrade      = var.allow_major_version_upgrade
  #availability_zones               = [data.aws_availability_zones.region_p.names[0], data.aws_availability_zones.region_p.names[1], data.aws_availability_zones.region_p.names[2]]
  db_subnet_group_name             = aws_db_subnet_group.private_p.name
  port                             = var.port #"5432"
  database_name                    = var.database_name
  master_username                  = var.username
  master_password                  = random_password.master_password.result
  #db_cluster_parameter_group_name  = aws_rds_cluster_parameter_group.aurora_cluster_parameter_group_p.id
  #db_instance_parameter_group_name = var.allow_major_version_upgrade ? aws_db_parameter_group.aurora_db_parameter_group_p.id : null
  backup_retention_period          = var.backup_retention_period
  preferred_backup_window          = var.preferred_backup_window
  #tfsec:ignore:aws-rds-encrypt-cluster-storage-data
  storage_encrypted               = var.storage_encrypted #true
  #kms_key_id                      = var.storage_encrypted ? aws_kms_key.kms_p[0].arn : null
  apply_immediately               = true
  #skip_final_snapshot             = var.skip_final_snapshot
  #final_snapshot_identifier       = var.skip_final_snapshot ? null : "${var.final_snapshot_identifier_prefix}-${var.identifier}-${var.region}-${random_id.snapshot_id.hex}"
  snapshot_identifier             = var.snapshot_identifier
  enabled_cloudwatch_logs_exports = local.logs_set
  tags                            = var.tags
  #depends_on = [
    # When this Aurora cluster is setup as a secondary, setting up the dependency makes sure to delete this cluster 1st before deleting current primary Cluster during terraform destroy
    # Comment out the following line if this cluster has changed role to be the primary Aurora cluster because of a failover for terraform destroy to work
    #aws_rds_cluster_instance.secondary,
  #]
  #lifecycle {
  #  ignore_changes = [
  #    replication_source_identifier,
      # Since Terraform doesn't allow to conditionally specify a lifecycle policy, this can't be done dynamically.
      # Uncomment the following line for Aurora Global Database to do major version upgrade as per https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_global_cluster
      # engine_version,
  #  ]
  }
}

#tfsec:ignore:aws-rds-enable-performance-insights-encryption tfsec:ignore:aws-rds-enable-performance-insights
resource "aws_rds_cluster_instance" "primary" {
  count                        = var.primary_instance_count #2
  #provider                     = aws.primary
  identifier                   = "${var.name}-${var.region}-${count.index + 1}"
  cluster_identifier           = aws_rds_cluster.primary.id
  engine                       = aws_rds_cluster.primary.engine
  #engine_version               = var.engine_version_pg
  auto_minor_version_upgrade   = var.auto_minor_version_upgrade #true
  instance_class               = var.instance_class
  #db_subnet_group_name         = aws_db_subnet_group.private_p.name
  #db_parameter_group_name      = aws_db_parameter_group.aurora_db_parameter_group_p.id
  performance_insights_enabled = true
  #monitoring_interval          = var.monitoring_interval
  monitoring_role_arn          = aws_iam_role.rds_enhanced_monitoring.arn
  apply_immediately            = true
  tags                         = var.tags
}


#############################
# RDS Aurora Parameter Groups
##############################

# resource "aws_rds_cluster_parameter_group" "aurora_cluster_parameter_group_p" {
#   provider    = aws.primary
#   name_prefix = "${var.name}-cluster-"
#   family      = data.aws_rds_engine_version.family.parameter_group_family
#   description = "aurora-cluster-parameter-group"

#   dynamic "parameter" {
#     for_each = var.engine == "aurora-postgresql" ? local.apg_cluster_pgroup_params : local.mysql_cluster_pgroup_params
#     iterator = pblock

#     content {
#       name         = pblock.value.name
#       value        = pblock.value.value
#       apply_method = pblock.value.apply_method
#     }
#   }
#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_db_parameter_group" "aurora_db_parameter_group_p" {
#   provider    = aws.primary
#   name_prefix = "${var.name}-db-"
#   family      = data.aws_rds_engine_version.family.parameter_group_family
#   description = "aurora-db-parameter-group"

#   dynamic "parameter" {
#     for_each = var.engine == "aurora-postgresql" ? local.apg_db_pgroup_params : local.mysql_db_pgroup_params
#     iterator = pblock

#     content {
#       name         = pblock.value.name
#       value        = pblock.value.value
#       apply_method = pblock.value.apply_method
#     }
#   }
#   lifecycle {
#     create_before_destroy = true
#   }
# }