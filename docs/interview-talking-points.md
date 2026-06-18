# Interview Talking Points

## 30-Second Version

I built a secure multi-tier AWS VPC using Terraform. The design separates public, private, and isolated data subnets across multiple Availability Zones. Public subnets host internet-facing components like an ALB and NAT Gateway, private subnets host application workloads, and the data tier has no default route to the internet. I used least-privilege Security Groups, subnet-level NACLs, VPC Endpoints, and VPC Flow Logs to show secure network design, visibility, and IaC-driven deployment.

## STAR Version

**Situation:**  
I wanted to build a practical AWS cloud security project that reflects how secure network foundations are designed in real environments.

**Task:**  
The objective was to design a production-style VPC using Terraform, with clear separation between public, private, and data tiers while applying least-privilege network access and visibility controls.

**Action:**  
I created a multi-AZ VPC with public subnets for internet-facing components, private subnets for application workloads, and isolated data subnets with no direct internet route. I configured route tables, NAT Gateway, Security Groups using least-privilege references, NACLs for subnet-level control, VPC Endpoints for private AWS service access, and VPC Flow Logs for network visibility. I also documented the security decisions and added Terraform validation and IaC security scanning.

**Result:**  
The final design reduced the public attack surface, isolated sensitive workloads, provided controlled outbound access, improved auditability through Flow Logs, and demonstrated how infrastructure can be deployed securely and repeatedly using Terraform.

## Questions You Should Be Ready To Answer

### Why not put application servers in public subnets?

Because application servers do not need to be directly reachable from the internet. Keeping them private reduces attack surface and forces inbound traffic through controlled entry points such as an ALB.

### Why does the data tier have no default route?

The data tier should not require general internet access. Removing the default route reduces exposure and helps prevent uncontrolled outbound communication from sensitive workloads.

### Why use NAT Gateway?

NAT Gateway allows private workloads to initiate outbound connections for updates, package retrieval, or API calls without allowing inbound internet connections to those workloads.

### What is the difference between Security Groups and NACLs?

Security Groups are stateful and apply to ENIs or workloads. NACLs are stateless and apply at the subnet level. Security Groups are better for fine-grained access control, while NACLs can provide subnet-wide guardrails or emergency blocks.

### Why use VPC Endpoints?

VPC Endpoints allow workloads to reach supported AWS services privately, without sending traffic through the public internet.

### How would you improve this for production?

I would add AWS WAF, AWS Network Firewall, GuardDuty, Security Hub, AWS Config, centralised Flow Logs, remote Terraform state, separate environments, and a controlled CI/CD deployment pipeline.

## CV Bullet

Designed and deployed a secure multi-tier AWS VPC using Terraform, including public, private, and isolated data subnets across multiple Availability Zones, least-privilege Security Groups, subnet-level NACL controls, NAT Gateway routing, VPC Endpoints, and VPC Flow Logs for network visibility and security auditing.

## LinkedIn Post Draft

I have been building a practical AWS cloud security project focused on secure VPC design using Terraform.

The project implements a multi-tier AWS network architecture with public, private, and isolated data subnets across multiple Availability Zones. It includes controlled routing, NAT Gateway outbound access, least-privilege Security Groups, subnet-level NACLs, VPC Endpoints, and VPC Flow Logs for visibility and audit readiness.

The main objective was not just to build a VPC, but to demonstrate how cloud security principles such as network segmentation, attack surface reduction, least privilege, logging, and infrastructure as code can be applied in a realistic AWS environment.

This project has helped me strengthen my understanding of secure AWS network architecture, Terraform, and practical cloud security design decisions.
