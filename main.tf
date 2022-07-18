######################################
# Defaults
######################################

# provider "aws" {
#   region = var.region
# }


######################################
# Create Aurora DB
######################################

#tfsec:ignore:aws-rds-enable-performance-insights-encryption tfsec:ignore:aws-rds-enable-performance-insights
module "aurora" {
  source     = "./modules/rds-aurora"
  region     = var.region
  #vpc_id                  = module.aurora_vpc.vpc_id
  private_subnet_ids_p     = var.private_subnet_ids_p #[module.aurora_vpc_p.private_subnet_1a_id, module.aurora_vpc_p.private_subnet_2a_id, module.aurora_vpc_p.private_subnet_3a_id]
  engine                   = var.engine
  engine_version_pg        = var.engine_version_pg
  username                 = var.username
  autoscaling_enabled      = true
  #tags                     = module.vpc_label.tags
  monitoring_interval      = var.monitoring_interval
  storage_encrypted        = var.storage_encrypted
  primary_instance_count   = var.primary_instance_count
}