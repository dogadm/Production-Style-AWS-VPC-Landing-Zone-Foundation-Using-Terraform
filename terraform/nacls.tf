# Network ACLs are stateless. These rules are intentionally explicit to demonstrate
# subnet-level boundaries. In many production environments, Security Groups remain
# the primary control and NACLs are used for coarse subnet guardrails or emergency blocks.

resource "aws_network_acl" "public" {
  # checkov:skip=CKV2_AWS_1: NACL is explicitly associated with public subnets through subnet_ids = aws_subnet.public[*].id; graph analysis does not resolve this association.
  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.public[*].id

  tags = {
    Name = "${local.name_prefix}-public-nacl"
    Tier = "public"
  }
}


# Public subnet intentionally permits HTTPS ingress from the internet.
# Security groups provide the stateful workload-level control.
#tfsec:ignore:aws-ec2-no-public-ingress-acl
resource "aws_network_acl_rule" "public_in_https" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}


# Required return-path ephemeral traffic for internet/NAT communication.
# Port 3389 is deliberately excluded as defense in depth.
#tfsec:ignore:aws-ec2-no-public-ingress-acl
resource "aws_network_acl_rule" "public_in_ephemeral_low" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 3388
}


# Required return-path ephemeral traffic for internet/NAT communication.
# Port 3389 is deliberately excluded as defense in depth.
#tfsec:ignore:aws-ec2-no-public-ingress-acl
resource "aws_network_acl_rule" "public_in_ephemeral_high" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 111
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 3390
  to_port        = 65535
}


# Public-subnet egress is intentionally broad to support NAT Gateway
# and public-tier return traffic. Workload-level egress is restricted
# with stateful security groups and private-subnet controls.
#tfsec:ignore:aws-ec2-no-excessive-port-access
resource "aws_network_acl_rule" "public_out_all" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}

resource "aws_network_acl" "private" {
  # checkov:skip=CKV2_AWS_1: NACL is explicitly associated with private subnets through subnet_ids = aws_subnet.private[*].id; graph analysis does not resolve this association.
  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "${local.name_prefix}-private-nacl"
    Tier = "private-application"
  }
}

resource "aws_network_acl_rule" "private_in_app_from_vpc" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = var.app_port
  to_port        = var.app_port
}

resource "aws_network_acl_rule" "private_in_ephemeral_from_vpc" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 1024
  to_port        = 65535
}


# Stateless NACL return path for internet connections initiated by private workloads via NAT.
# Port 3389 is deliberately excluded.
#tfsec:ignore:aws-ec2-no-public-ingress-acl
resource "aws_network_acl_rule" "private_in_ephemeral_from_internet_return_low" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 120
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 3388
}


# Stateless NACL return path for internet connections initiated by private workloads via NAT.
# Port 3389 is deliberately excluded.
#tfsec:ignore:aws-ec2-no-public-ingress-acl
resource "aws_network_acl_rule" "private_in_ephemeral_from_internet_return_high" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 121
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 3390
  to_port        = 65535
}

resource "aws_network_acl_rule" "private_out_https" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 100
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "private_out_db_to_data" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 110
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = var.db_port
  to_port        = var.db_port
}

resource "aws_network_acl_rule" "private_out_ephemeral_to_vpc" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 120
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl" "data" {
  # checkov:skip=CKV2_AWS_1: NACL is explicitly associated with data subnets through subnet_ids = aws_subnet.data[*].id; graph analysis does not resolve this association.

  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.data[*].id

  tags = {
    Name = "${local.name_prefix}-data-nacl"
    Tier = "isolated-data"
  }
}

resource "aws_network_acl_rule" "data_in_db_from_vpc" {
  network_acl_id = aws_network_acl.data.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = var.db_port
  to_port        = var.db_port
}

resource "aws_network_acl_rule" "data_in_https_from_vpc" {
  network_acl_id = aws_network_acl.data.id
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "data_in_ephemeral_from_vpc" {
  network_acl_id = aws_network_acl.data.id
  rule_number    = 120
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "data_out_https_to_vpc" {
  network_acl_id = aws_network_acl.data.id
  rule_number    = 100
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "data_out_ephemeral_to_vpc" {
  network_acl_id = aws_network_acl.data.id
  rule_number    = 110
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 1024
  to_port        = 65535
}
