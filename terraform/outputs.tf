output "vpc_id" {
  description = "ID of the created VPC."
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the created VPC."
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private application subnets."
  value       = aws_subnet.private[*].id
}

output "data_subnet_ids" {
  description = "IDs of the isolated data subnets."
  value       = aws_subnet.data[*].id
}

output "alb_security_group_id" {
  description = "Security Group ID for the public ALB tier."
  value       = aws_security_group.alb.id
}

output "app_security_group_id" {
  description = "Security Group ID for the private application tier."
  value       = aws_security_group.app.id
}

output "db_security_group_id" {
  description = "Security Group ID for the isolated database tier."
  value       = aws_security_group.db.id
}

output "nat_gateway_ids" {
  description = "NAT Gateway IDs."
  value       = aws_nat_gateway.main[*].id
}

output "cloudwatch_flow_log_group" {
  description = "CloudWatch Log Group used for VPC Flow Logs."
  value       = var.enable_flow_logs ? aws_cloudwatch_log_group.vpc_flow_logs[0].name : null
}

output "s3_flow_logs_bucket" {
  description = "S3 bucket used for long-term VPC Flow Log storage."
  value       = var.enable_flow_logs ? aws_s3_bucket.flow_logs[0].bucket : null
}

output "interface_endpoint_ids" {
  description = "Interface VPC Endpoint IDs."
  value       = { for service, endpoint in aws_vpc_endpoint.interface : service => endpoint.id }
}

output "s3_gateway_endpoint_id" {
  description = "S3 Gateway VPC Endpoint ID."
  value       = var.enable_s3_gateway_endpoint ? aws_vpc_endpoint.s3[0].id : null
}
