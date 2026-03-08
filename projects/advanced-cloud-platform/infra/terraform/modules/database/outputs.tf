output "database_endpoint" {
  value = "${var.project_name}-${var.environment}.${var.engine}.internal"
}
