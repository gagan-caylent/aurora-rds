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
  source                   = "./modules/rds-aurora"
  region                   = var.region
  sec_region               = var.sec_region
  private_subnet_ids_p     = var.private_subnet_ids_p #[module.aurora_vpc_p.private_subnet_1a_id, module.aurora_vpc_p.private_subnet_2a_id, module.aurora_vpc_p.private_subnet_3a_id]
  engine                   = var.engine
  engine_version_pg        = var.engine_version_pg
  username                 = var.username
  autoscaling_enabled      = true
  #tags                     = module.vpc_label.tags
  monitoring_interval      = var.monitoring_interval
  storage_encrypted        = var.storage_encrypted
  primary_instance_count   = var.primary_instance_count
  secondary_instance_count = var.secondary_instance_count
  vpc_id                   = var.vpc_id 
  # vault_name               = "database-vault"
  # plan_name                = "database-backup-plan"
  # rules = [
  #   {
  #     name                     = "rule-1"
  #     schedule                 = "cron(0 2 * * ? *)"
  #     target_vault_name        = "database-vault"
  #     start_window             = 60
  #     completion_window        = 360
  #     #enable_continuous_backup = true
  #     # lifecycle = {
  #     #   cold_storage_after = 0
  #     #   delete_after       = 30
  #     # },
  #     copy_actions = [
  #       {
  #         # lifecycle = {
  #         #   cold_storage_after = 0
  #         #   delete_after       = 90
  #         # },
  #         destination_vault_arn = "arn:aws:backup:us-east-2:131578276461:backup-vault:Aurora_db_backups_copy"
  #       }
  #     ]
  #     # recovery_point_tags = {
  #     #   Environment = "production"
  #     # }
  #   } 
  # ] 
}