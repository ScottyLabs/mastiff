variable "identifier" {
  description = "Identifier for the ElastiCache resources"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID where the ElastiCache cluster will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet IDs for the ElastiCache subnet group"
  type        = list(string)
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to connect to the ElastiCache cluster"
  type        = list(string)
}

variable "instance_type" {
  description = "The compute and memory capacity of the nodes in the cluster"
  type        = string
  default     = "cache.t3.micro"
}

variable "engine" {
  description = "The name of the cache engine to be used (e.g., redis, memcached)"
  type        = string
  default     = "redis"
}

variable "engine_version" {
  description = "The version number of the cache engine"
  type        = string
  default     = "7.0" # Defaulting to a recent Redis version
}

variable "parameter_group_family" {
  description = "The family of the ElastiCache parameter group"
  type        = string
  default     = "redis7" # Needs to match the engine and version
}

variable "port" {
  description = "The port number on which the cache engine will accept connections"
  type        = number
  default     = 6379 # Default Redis port
}

variable "num_cache_nodes" {
  description = "The number of cache nodes that the cache cluster should have"
  type        = number
  default     = 3
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
