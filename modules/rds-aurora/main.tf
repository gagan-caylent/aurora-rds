
#########################
# Collect data
#########################

data "aws_availability_zones" "region_p" {
  state    = "available"
  filter{
    name = "zone-type"
    values = ["availability-zone"]
  }
  
}

# data "aws_availability_zones" "region_p" {
#   all_availability_zones = true
#   filter {
#     name   = "group-name"
#     values = ["us-east-1"]
#   }
# }

# data "aws_availability_zones" "region_s" {
#   state    = "available"
#   provider = aws.secondary
# }



#########################
# Create Unique password
#########################

resource "random_password" "master_password" {
  length  = 10
  special = false
}


####################################
# Generate Final snapshot identifier
####################################

resource "random_id" "snapshot_id" {

  keepers = {
    id = var.identifier
  }

  byte_length = 4
}


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
  #path                = "/"
  name                = "rds-enhanced-monitoring-role-demo"
  assume_role_policy  = data.aws_iam_policy_document.monitoring_rds_assume_role.json
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"]
  tags                = var.tags
}


###########
# DB Subnet
###########

resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "aurora-subnet-group"
  subnet_ids = var.private_subnet_ids_p
  tags = {
    Name = "My DB subnet group"
  }
}



########
# AURORA
########


resource "aws_rds_cluster" "aurora_cluster" {
  #provider                         = aws.primary
  #global_cluster_identifier        = var.setup_globaldb ? aws_rds_global_cluster.globaldb[0].id : null
  cluster_identifier               = "${var.identifier}-${var.region}"
  engine                           = var.engine #"aurora-postgresql"
  engine_version                   = var.engine_version_pg
  #allow_major_version_upgrade      = var.allow_major_version_upgrade
  availability_zones               = [data.aws_availability_zones.region_p.names[0], data.aws_availability_zones.region_p.names[1], data.aws_availability_zones.region_p.names[2]]
  db_subnet_group_name             = aws_db_subnet_group.aurora_subnet_group.name
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
  skip_final_snapshot             = var.skip_final_snapshot
  final_snapshot_identifier       = var.skip_final_snapshot ? null : "${var.final_snapshot_identifier_prefix}-${var.identifier}-${var.region}-${random_id.snapshot_id.hex}"
  enabled_cloudwatch_logs_exports = local.logs_set
  tags                            = var.tags
 
}

#tfsec:ignore:aws-rds-enable-performance-insights-encryption tfsec:ignore:aws-rds-enable-performance-insights
resource "aws_rds_cluster_instance" "primary" {
  count                        = var.primary_instance_count #2
  #provider                     = aws.primary
  identifier                   = "${var.name}-${var.region}-${count.index + 1}"
  cluster_identifier           = aws_rds_cluster.aurora_cluster.id
  engine                       = aws_rds_cluster.aurora_cluster.engine
  engine_version               = var.engine_version_pg
  auto_minor_version_upgrade   = var.auto_minor_version_upgrade #true
  instance_class               = var.instance_class
  db_subnet_group_name         = aws_db_subnet_group.aurora_subnet_group.name
  #db_parameter_group_name      = aws_db_parameter_group.aurora_db_parameter_group_p.id
  performance_insights_enabled = true
  monitoring_interval          = var.monitoring_interval
  monitoring_role_arn          = aws_iam_role.rds_enhanced_monitoring.arn
  apply_immediately            = true
  tags                         = var.tags
}


################################################################################
# Security Group
################################################################################

resource "aws_security_group" "aurora_sg" {
  count = var.create_security_group ? 1 : 0

  name        = "aurora-sg"
  #name_prefix = var.security_group_use_name_prefix ? "${var.name}-" : null
  vpc_id      = var.vpc_id
  description = "Control traffic to/from RDS Aurora"

  tags = var.tags
  lifecycle {
    create_before_destroy = true
  }
}

# TODO - change to map of ingress rules under one resource at next breaking change
resource "aws_security_group_rule" "aurora_sg_ingress" {
 

  description = "From allowed SGs"

  type                     = "ingress"
  from_port                = var.port
  to_port                  = var.port
  protocol                 = "tcp"
  #source_security_group_id = element(var.allowed_security_groups, count.index)
  security_group_id        = aws_security_group.aurora_sg.id
  self = true
}


resource "aws_security_group_rule" "aurora_sg_egress" {
 
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  #source_security_group_id = element(var.allowed_security_groups, count.index)
  security_group_id        = aws_security_group.aurora_sg.id
  
}

################################################################################
# Autoscaling
################################################################################

resource "aws_appautoscaling_target" "aurora_scaling_target" {
  count = var.autoscaling_enabled ? 1 : 0

  max_capacity       = var.autoscaling_max_capacity
  min_capacity       = var.autoscaling_min_capacity
  resource_id        = "cluster:${aws_rds_cluster.aurora_cluster.cluster_identifier}"
  scalable_dimension = "rds:cluster:ReadReplicaCount"
  service_namespace  = "rds"
}

resource "aws_appautoscaling_policy" "aurora_scaling_policy" {
  count = var.autoscaling_enabled ? 1 : 0

  name               = "target-metric"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "cluster:${aws_rds_cluster.aurora_cluster.cluster_identifier}"
  scalable_dimension = "rds:cluster:ReadReplicaCount"
  service_namespace  = "rds"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = var.predefined_metric_type
    }

    scale_in_cooldown  = var.autoscaling_scale_in_cooldown
    scale_out_cooldown = var.autoscaling_scale_out_cooldown
    target_value       = var.predefined_metric_type == "RDSReaderAverageCPUUtilization" ? var.autoscaling_target_cpu : var.autoscaling_target_connections
  }

  depends_on = [
    aws_appautoscaling_target.aurora_scaling_target
  ]
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