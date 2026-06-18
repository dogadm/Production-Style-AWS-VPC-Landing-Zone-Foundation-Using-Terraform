# Threat Model

## Assets Protected

- Application workloads in private subnets
- Databases and sensitive services in isolated data subnets
- VPC Flow Logs stored in CloudWatch Logs and S3
- Network paths between public, private, and data tiers

## Key Threats and Mitigations

| Threat | Risk | Mitigation |
|---|---|---|
| Internet scanning of application servers | Attackers discover and target exposed workloads | Application servers are placed in private subnets with no public IPs |
| Direct database exposure | Sensitive data compromise | Databases are placed in isolated data subnets with no default internet route |
| Overly broad Security Groups | Lateral movement and unnecessary exposure | SG references restrict traffic between ALB, app, and DB tiers |
| Uncontrolled outbound traffic | Data exfiltration and command-and-control paths | Data tier has no default route; private tier can be enhanced with egress filtering |
| Lack of network visibility | Difficult incident investigation | VPC Flow Logs are enabled to CloudWatch and S3 |
| IaC misconfiguration | Insecure resources deployed repeatedly | Terraform validation and IaC scanning are included in CI |
| Single AZ dependency | Service disruption during AZ impairment | Network tiers are deployed across multiple AZs |

## Trust Boundaries

```text
Internet
  |
  | Boundary 1: Public ingress through ALB Security Group
  v
Public Subnet Tier
  |
  | Boundary 2: ALB SG -> App SG only
  v
Private Application Tier
  |
  | Boundary 3: App SG -> DB SG only
  v
Isolated Data Tier
```

## Residual Risks

This project creates the network foundation but does not fully implement:

- Web application firewalling
- Full IDS/IPS inspection
- Centralised multi-account logging
- Runtime workload hardening
- Secrets management
- Patch management
- Application authentication and authorisation

## Production Recommendations

- Place AWS WAF in front of public web entry points
- Add AWS Network Firewall for inspected ingress and egress paths
- Send Flow Logs to a central logging account
- Enable GuardDuty and Security Hub
- Use AWS Config rules to monitor network drift
- Restrict ALB ingress to CloudFront or approved CIDRs where appropriate
- Use least-privilege IAM roles for workloads
