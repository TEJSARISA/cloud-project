variable "project_name" {
  type        = string
  description = "Project identifier"
  default     = "advanced-cloud-platform"
}

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "dev"
}

variable "cidr_block" {
  type        = string
  description = "Network CIDR block"
  default     = "10.20.0.0/16"
}

variable "private_subnet_count" {
  type        = number
  default     = 2
}

variable "public_subnet_count" {
  type        = number
  default     = 2
}

variable "desired_node_count" {
  type        = number
  default     = 3
}

variable "node_instance_class" {
  type        = string
  default     = "general-purpose.medium"
}

variable "db_engine" {
  type        = string
  default     = "postgres"
}

variable "db_engine_version" {
  type        = string
  default     = "15"
}

variable "db_instance_class" {
  type        = string
  default     = "db.standard.medium"
}

variable "db_storage_gb" {
  type        = number
  default     = 100
}

variable "db_multi_az" {
  type        = bool
  default     = true
}
