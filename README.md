## Scenario

A company is deploying a web application into AWS and needs a secure network foundation that separates internet-facing resources from application workloads and sensitive data stores.

The goal of this project is to design and deploy a production-style AWS VPC using Terraform, with a clear separation between public, private, and isolated data subnet tiers. The architecture supports high availability across two Availability Zones, controlled outbound access through NAT Gateways, private access to AWS services through VPC Endpoints, and network visibility using VPC Flow Logs.

The project focuses on cloud security principles such as least privilege, attack surface reduction, network segmentation, secure routing, infrastructure as code, and operational visibility.
