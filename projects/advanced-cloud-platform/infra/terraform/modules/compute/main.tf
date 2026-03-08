resource "null_resource" "compute" {
  triggers = {
    project_name        = var.project_name
    environment         = var.environment
    desired_node_count  = var.desired_node_count
    node_instance_class = var.node_instance_class
    network_id          = var.network_id
  }
}
