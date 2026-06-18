# Cost Considerations

This project creates resources that may incur AWS cost, especially NAT Gateways and Interface VPC Endpoints.

## Cost-Sensitive Resources

| Resource | Cost Concern | Mitigation |
|---|---|---|
| NAT Gateway | Hourly charge and data processing charge | Use `single_nat_gateway = true` in demos or disable when not testing |
| Interface VPC Endpoints | Hourly charge per AZ and data processing charge | Create only required endpoints |
| CloudWatch Logs | Log ingestion and storage cost | Use retention policy such as 30 days |
| S3 Flow Log bucket | Storage cost | Use lifecycle expiration |
| Elastic IP | May incur cost if unused | Destroy resources after testing |

## Learning Environment Recommendation

For a low-cost demo, use:

```hcl
single_nat_gateway = true
enable_flow_logs  = true
interface_endpoint_services = ["ssm", "ssmmessages", "ec2messages"]
```

For the lowest-cost dry run, use:

```hcl
enable_nat_gateway = false
enable_flow_logs   = false
interface_endpoint_services = []
enable_s3_gateway_endpoint = false
```

## Cleanup

Destroy the environment after testing:

```bash
cd terraform
terraform destroy
```
