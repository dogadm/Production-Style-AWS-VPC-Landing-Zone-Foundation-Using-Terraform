# Validation Evidence

Use this file to capture proof that the architecture was deployed, validated, and scanned.

## 1. Terraform Formatting

Command:

```bash
terraform fmt -check
```

Expected result:

```text
No output means formatting passed.
```

Paste your result here:

```text
TODO
```

## 2. Terraform Validation

Command:

```bash
terraform validate
```

Expected result:

```text
Success! The configuration is valid.
```

Paste your result here:

```text
TODO
```

## 3. Terraform Plan

Command:

```bash
terraform plan
```

Capture evidence of resources to be created:

```text
TODO
```

## 4. AWS Resource Validation

### VPC

```bash
aws ec2 describe-vpcs --filters "Name=tag:Project,Values=secure-vpc"
```

Evidence:

```text
TODO
```

### Subnets

```bash
aws ec2 describe-subnets --filters "Name=vpc-id,Values=<vpc-id>"
```

Evidence:

```text
TODO
```

### Route Tables

```bash
aws ec2 describe-route-tables --filters "Name=vpc-id,Values=<vpc-id>"
```

Evidence:

```text
TODO
```

### Security Groups

```bash
aws ec2 describe-security-groups --filters "Name=vpc-id,Values=<vpc-id>"
```

Evidence:

```text
TODO
```

### VPC Endpoints

```bash
aws ec2 describe-vpc-endpoints --filters "Name=vpc-id,Values=<vpc-id>"
```

Evidence:

```text
TODO
```

### VPC Flow Logs

```bash
aws ec2 describe-flow-logs --filter "Name=resource-id,Values=<vpc-id>"
```

Evidence:

```text
TODO
```

## 5. IaC Security Scanning

### TFLint

```bash
tflint --init
tflint
```

Evidence:

```text
TODO
```

### tfsec

```bash
tfsec .
```

Evidence:

```text
TODO
```

### Checkov

```bash
checkov -d .
```

Evidence:

```text
TODO
```

## 6. Screenshots to Add

Add screenshots showing:

- VPC overview
- Subnet list showing public, private, and data tiers
- Route tables showing no default route in data tier
- Security Groups showing SG-to-SG references
- VPC Flow Logs enabled
- VPC Endpoints created
- Terraform plan or apply output
- CI pipeline passing checks
