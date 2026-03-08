resource "null_resource" "network" {
  triggers = {
    project_name         = var.project_name
    environment          = var.environment
    cidr_block           = var.cidr_block
    private_subnet_count = var.private_subnet_count
    public_subnet_count  = var.public_subnet_count
  }
}
