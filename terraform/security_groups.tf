resource "aws_security_group" "alb" {
  name        = "${local.name_prefix}-alb-sg"
  description = "Allow HTTPS from approved CIDRs and forward only to application tier."
  vpc_id      = aws_vpc.main.id

  ingress = []
  egress  = []

  tags = {
    Name = "${local.name_prefix}-alb-sg"
    Tier = "public"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_https_from_internet" {
  for_each = toset(var.allowed_alb_ingress_cidrs)

  security_group_id = aws_security_group.alb.id
  description       = "HTTPS ingress to ALB from approved CIDR."
  cidr_ipv4         = each.value
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "alb_to_app" {
  security_group_id            = aws_security_group.alb.id
  description                  = "ALB forwards requests only to application security group."
  referenced_security_group_id = aws_security_group.app.id
  from_port                    = var.app_port
  ip_protocol                  = "tcp"
  to_port                      = var.app_port
}

resource "aws_security_group" "app" {
  name        = "${local.name_prefix}-app-sg"
  description = "Application tier accepts traffic only from ALB security group."
  vpc_id      = aws_vpc.main.id

  ingress = []
  egress  = []

  tags = {
    Name = "${local.name_prefix}-app-sg"
    Tier = "private-application"
  }
}

resource "aws_vpc_security_group_ingress_rule" "app_from_alb" {
  security_group_id            = aws_security_group.app.id
  description                  = "Application accepts traffic only from ALB security group."
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = var.app_port
  ip_protocol                  = "tcp"
  to_port                      = var.app_port
}

resource "aws_vpc_security_group_egress_rule" "app_to_db" {
  security_group_id            = aws_security_group.app.id
  description                  = "Application connects to database security group only on database port."
  referenced_security_group_id = aws_security_group.db.id
  from_port                    = var.db_port
  ip_protocol                  = "tcp"
  to_port                      = var.db_port
}

resource "aws_vpc_security_group_egress_rule" "app_https_outbound" {
  security_group_id = aws_security_group.app.id
  description       = "Application outbound HTTPS for patching, APIs, and VPC Endpoints."
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_security_group" "db" {
  name        = "${local.name_prefix}-db-sg"
  description = "Database tier accepts traffic only from application security group."
  vpc_id      = aws_vpc.main.id

  ingress = []
  egress  = []

  tags = {
    Name = "${local.name_prefix}-db-sg"
    Tier = "isolated-data"
  }
}

resource "aws_vpc_security_group_ingress_rule" "db_from_app" {
  security_group_id            = aws_security_group.db.id
  description                  = "Database accepts traffic only from application security group."
  referenced_security_group_id = aws_security_group.app.id
  from_port                    = var.db_port
  ip_protocol                  = "tcp"
  to_port                      = var.db_port
}

resource "aws_security_group" "vpc_endpoints" {
  name        = "${local.name_prefix}-vpce-sg"
  description = "Security group for Interface VPC Endpoints."
  vpc_id      = aws_vpc.main.id

  ingress = []
  egress  = []

  tags = {
    Name = "${local.name_prefix}-vpce-sg"
    Tier = "shared-services"
  }
}

resource "aws_vpc_security_group_ingress_rule" "vpce_https_from_vpc" {
  security_group_id = aws_security_group.vpc_endpoints.id
  description       = "Allow HTTPS from workloads inside the VPC to Interface VPC Endpoints."
  cidr_ipv4         = var.vpc_cidr
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "vpce_egress_to_vpc" {
  security_group_id = aws_security_group.vpc_endpoints.id
  description       = "Allow endpoint return traffic inside the VPC."
  cidr_ipv4         = var.vpc_cidr
  ip_protocol       = "-1"
}
