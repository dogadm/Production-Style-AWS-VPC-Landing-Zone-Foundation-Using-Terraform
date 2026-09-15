resource "aws_vpc_endpoint" "interface" {
  for_each = toset(var.interface_endpoint_services)

  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.${each.value}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name = "${local.name_prefix}-${each.value}-vpce"
    Type = "interface"
  }
}



resource "aws_vpc_endpoint" "s3" {
  count = var.enable_s3_gateway_endpoint ? 1 : 0

  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"

  # Gateway endpoints are associated only with private application
  # route tables. Isolated data subnets do not require direct S3
  # access and therefore remain without this service route.

  route_table_ids = aws_route_table.private[*].id

  tags = {
    Name = "${local.name_prefix}-s3-gateway-vpce"
    Type = "gateway"
  }
}

resource "aws_vpc_endpoint" "dynamodb" {
  count = var.enable_dynamodb_gateway_endpoint ? 1 : 0

  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = aws_route_table.private[*].id

  tags = {
    Name = "${local.name_prefix}-dynamodb-gateway-vpce"
    Type = "gateway"
  }
}
