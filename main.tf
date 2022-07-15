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
  #sec_region = var.sec_region
  #vpc_id                  = module.aurora_vpc.vpc_id
  private_subnet_ids_p     = var.private_subnet_ids_p #[module.aurora_vpc_p.private_subnet_1a_id, module.aurora_vpc_p.private_subnet_2a_id, module.aurora_vpc_p.private_subnet_3a_id]
  #private_subnet_ids_s     = var.setup_globaldb ? [module.aurora_vpc_s.private_subnet_1a_id, module.aurora_vpc_s.private_subnet_2a_id, module.aurora_vpc_s.private_subnet_3a_id] : null
  engine                   = var.engine
  engine_version_pg        = var.engine_version_pg
  #engine_version_mysql     = var.engine_version_mysql
  username                 = var.username
  #password                 = var.password
  #setup_globaldb           = var.setup_globaldb
  #setup_as_secondary       = var.setup_as_secondary
  #tags                     = module.vpc_label.tags
  monitoring_interval      = var.monitoring_interval
  storage_encrypted        = var.storage_encrypted
  primary_instance_count   = var.primary_instance_count
  #secondary_instance_count = var.secondary_instance_count
  #snapshot_identifier      = var.snapshot_identifier
}