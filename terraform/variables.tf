variable "aws_region" {
  description = "AWS region where resources will be deployed."
  type        = string
  default     = "eu-west-2"
}

variable "project_name" {
  description = "Project name used for resource naming and tagging."
  type        = string
  default     = "secure-vpc"
}

variable "environment" {
  description = "Environment name, such as dev, test, or prod."
  type        = string
  default     = "dev"
}

variable "az_count" {
  description = "Number of Availability Zones to use."
  type        = number
  default     = 2

  validation {
    condition     = var.az_count >= 2
    error_message = "Use at least two Availability Zones for high availability."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private application subnets."
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "data_subnet_cidrs" {
  description = "CIDR blocks for isolated data subnets."
  type        = list(string)
  default     = ["10.0.100.0/24", "10.0.200.0/24"]
}

variable "allowed_alb_ingress_cidrs" {
  description = "CIDR blocks allowed to reach the ALB security group over HTTPS. Use a restricted CIDR for real environments."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "app_port" {
  description = "Application port allowed from the ALB security group to the application security group."
  type        = number
  default     = 8080
}

variable "db_port" {
  description = "Database port allowed from the application security group to the database security group."
  type        = number
  default     = 5432
}

variable "enable_nat_gateway" {
  description = "Whether to deploy NAT Gateway resources for private subnet outbound access."
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway to reduce cost. Set false for one NAT Gateway per AZ."
  type        = bool
  default     = false
}

variable "enable_flow_logs" {
  description = "Whether to enable VPC Flow Logs to CloudWatch Logs and S3."
  type        = bool
  default     = true
}

variable "flow_log_retention_days" {
  description = "CloudWatch log retention period for VPC Flow Logs."
  type        = number
  default     = 30
}

variable "interface_endpoint_services" {
  description = "AWS services to expose through Interface VPC Endpoints."
  type        = list(string)
  default     = ["ssm", "ssmmessages", "ec2messages", "logs", "sts"]
}

variable "enable_s3_gateway_endpoint" {
  description = "Whether to create an S3 Gateway VPC Endpoint."
  type        = bool
  default     = true
}

variable "enable_dynamodb_gateway_endpoint" {
  description = "Whether to create a DynamoDB Gateway VPC Endpoint."
  type        = bool
  default     = false
}
