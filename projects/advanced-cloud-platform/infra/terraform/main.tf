terraform {
  required_version = ">= 1.5.0"

  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

module "network" {
  source               = "./modules/network"
  project_name         = var.project_name
  environment          = var.environment
  cidr_block           = var.cidr_block
  private_subnet_count = var.private_subnet_count
  public_subnet_count  = var.public_subnet_count
}

module "compute" {
  source              = "./modules/compute"
  project_name        = var.project_name
  environment         = var.environment
  desired_node_count  = var.desired_node_count
  node_instance_class = var.node_instance_class
  network_id          = module.network.network_id
}

module "database" {
  source          = "./modules/database"
  project_name    = var.project_name
  environment     = var.environment
  network_id      = module.network.network_id
  engine          = var.db_engine
  engine_version  = var.db_engine_version
  instance_class  = var.db_instance_class
  storage_gb      = var.db_storage_gb
  multi_az        = var.db_multi_az
}
