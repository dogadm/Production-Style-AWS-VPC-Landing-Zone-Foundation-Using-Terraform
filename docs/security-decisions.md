# Security Decisions

## 1. Why are application servers placed in private subnets?

Application servers do not need to be directly reachable from the internet. Placing them in private subnets reduces the external attack surface and ensures inbound traffic reaches them only through a controlled entry point, such as an Application Load Balancer.

## 2. Why is the data tier isolated?

The data tier uses dedicated subnets with no default route to the internet. This limits exposure of sensitive systems and supports a stronger segmentation model. Access to the data tier is allowed only from the application Security Group on the required database port.

## 3. Why use Security Group references?

Security Group references are used instead of broad CIDR-based rules because they create tighter workload-to-workload controls. For example, the database Security Group allows traffic only from the application Security Group, not from the whole VPC CIDR.

## 4. Why enable VPC Flow Logs?

VPC Flow Logs provide visibility into accepted and rejected network traffic metadata. This supports troubleshooting, anomaly investigation, incident response, and audit review.

## 5. Why use VPC Endpoints?

VPC Endpoints allow private connectivity to supported AWS services without routing traffic through the public internet. This reduces unnecessary internet exposure and supports more controlled egress design.

## 6. Why use NAT Gateway for private subnets?

NAT Gateway allows private workloads to make outbound requests for patching, package downloads, and API calls without making those workloads reachable from the internet.

## 7. Why does the data tier have no NAT route?

Databases and sensitive data services should not require general outbound internet access. If they need AWS service access, that should be provided through specific VPC Endpoints.

## 8. Why use Terraform?

Terraform makes the infrastructure repeatable, reviewable, version-controlled, and suitable for automated security checks before deployment.

## 9. Why include NACLs if Security Groups exist?

Security Groups provide fine-grained, stateful workload-level control. NACLs provide stateless subnet-level guardrails. In this project, NACLs demonstrate an additional layer of defense, but Security Groups remain the primary access control mechanism.

## 10. What would be added in production?

A production version would likely include AWS Network Firewall, AWS WAF, centralised logging, GuardDuty, Security Hub, AWS Config rules, and deployment through a controlled CI/CD pipeline with manual approval before Terraform apply.
