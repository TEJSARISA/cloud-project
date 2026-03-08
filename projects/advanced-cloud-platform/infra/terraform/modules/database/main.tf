resource "null_resource" "database" {
  triggers = {
    project_name   = var.project_name
    environment    = var.environment
    network_id     = var.network_id
    engine         = var.engine
    engine_version = var.engine_version
    instance_class = var.instance_class
    storage_gb     = var.storage_gb
    multi_az       = var.multi_az
  }
}
