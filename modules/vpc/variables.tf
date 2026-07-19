variable "name" {
  description = "VPC Name"
  type        = string
}

variable "cidr" {
  description = "VPC CIDR Block"
  type        = string
}

variable "azs" {
  description = "Availability Zones"
  type        = list(string)
}

variable "public_subnets" {
  description = "Public Subnets"
  type        = list(string)
}

variable "private_subnets" {
  description = "Private Subnets"
  type        = list(string)
}

variable "tags" {
  description = "Common Tags"
  type        = map(string)
  default     = {}
}