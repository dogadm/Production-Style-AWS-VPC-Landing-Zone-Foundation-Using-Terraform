# Architecture Explanation

## Objective

The objective is to design a secure AWS network foundation that separates internet-facing resources, application workloads, and sensitive data workloads into different trust zones.

## Design Principles

1. **Minimise public exposure**  
   Only the public tier has a route to the Internet Gateway. Application and data workloads are placed in non-public subnets.

2. **Use multiple Availability Zones**  
   Public, private, and data subnet tiers are deployed across at least two Availability Zones to support high availability.

3. **Apply least privilege at the network layer**  
   Security Groups reference other Security Groups rather than allowing broad CIDR ranges wherever possible.

4. **Avoid direct internet access for sensitive workloads**  
   The data subnets have no default route to the internet.

5. **Enable network visibility**  
   VPC Flow Logs capture accepted and rejected traffic metadata for troubleshooting, audit, and investigation.

## Subnet Tiers

### Public Subnets

Public subnets contain resources that must interact directly with the internet, such as an Application Load Balancer or NAT Gateway.

Security consideration: public subnets should not host databases or sensitive internal workloads.

### Private Application Subnets

Private subnets host application workloads. They do not have a direct route to the Internet Gateway. Outbound internet access is provided through NAT Gateway where enabled.

Security consideration: workloads in this tier are not directly reachable from the internet. Inbound traffic should arrive through the ALB Security Group.

### Isolated Data Subnets

Data subnets host databases or sensitive services. These subnets have no default route to the internet.

Security consideration: database access is limited to the application Security Group on the required database port.

## Routing Model

| Route Table | Default Route | Purpose |
|---|---|---|
| Public | `0.0.0.0/0 -> Internet Gateway` | Internet-facing tier |
| Private | `0.0.0.0/0 -> NAT Gateway` | Outbound-only application access |
| Data | No default route | Isolated sensitive workloads |

## Traffic Flow

### Inbound User Request

```text
Internet -> Internet Gateway -> ALB -> Application Tier -> Database Tier
```

### Private Outbound Request

```text
Application Tier -> NAT Gateway -> Internet Gateway -> Internet
```

### Data Tier

```text
Database Tier -> No default internet route
```

Where AWS service access is required, use VPC Endpoints instead of routing over the public internet.
