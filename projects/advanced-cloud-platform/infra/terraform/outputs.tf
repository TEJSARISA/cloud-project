output "network_id" {
  value = module.network.network_id
}

output "cluster_id" {
  value = module.compute.cluster_id
}

output "database_endpoint" {
  value = module.database.database_endpoint
}
