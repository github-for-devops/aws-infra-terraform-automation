# Application Deployment On AWS Using Terraform

## Description

This project provisions a **production-ready AWS infrastructure** using Terraform. To deploy application on AWS Cloud with automated infra deployment.

## Architecture Digram

![Image](./image/application_aws_infra.jpg)

## Prerequisite To Deploy Solution

#### Tools

Ensure that **terraform** and **aws** cli is installed with respective permission to create resources. Here are some reference link:
> **[terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)** and **[aws](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)** installation links.

**Note:** Permissions required to run the solution excluded for now and user must follow least-privilages for resource creation.

### S3 bucket creation For Remote Backend

- Ensure to create an s3 bucket to store the state file remotely in the respective region based on requirement.
- Ensure to make the necessary changes within the [backend.tf](./backend.tf) file based on the bucket created in the above step.

## Deployment Steps

1. **Initialize Terraform:**
```bash
terraform init
```
2. **Review the execution plan:**
```bash
terraform plan
```
3. **Excecute the terraform code to create the infrastructure:**
```bash
terraform apply
```

## Architecture Decisions

- **Multi-AZ Deployment**: Resources are deployed across two Availability Zones to ensure high availability and fault tolerance.

- **Private Subnets for EC2**: Application instances are placed in private subnets to prevent direct internet exposure.

- **Application Load Balancer (ALB)**: Used as the entry point to distribute incoming traffic across multiple EC2 instances so application stack are kept private.

- **Auto Scaling Group (ASG)**: Ensures the application remains highly available and automatically adjusts capacity based on demand, aslo dynamic scailing policy applied based on cpu usage.

- **NAT Gateway**: Allows private instances to access the internet securely for updates and package installation without being publicly exposed.

- **Monitoring and Alerting**: Infrastructure components are monitiored and critical alarms are set to prevent application disruption.

- **Terraform Modules**: Infrastructure is split into reusable modules (network, auto-scailing resources including lb, Security, monitoring and alerting) for better maintainability and scalability.

- **Remote State Management**: Terraform state is stored in S3 with user locking to prevent concurrent modifications.

## Cost Estimate and Optimization Recommendations

Get the detailed estimated cost for deploying the solution in below link:

**[AWS Pricing Calculator Link](https://calculator.aws/#/estimate?id=df1874d0611973934b272ad579ac9359409a90e1)**

**Cosiderations**:
- Above pricing link includes regional nate-gateway pricing by default so the actual cost of vpc nate-gateway is **41.16 USD** per month.
- Currently Ec2 instance size and Compute saving plan is selected with 1 year no upfront commitment considering new application. Can be refactor in future as per recommendations by cost-optimization hub recommendations or as per right sizing required based on metrics data and cost-explorer pattern for atleast 6 month of data.
- AWS Budget and alarm is setup based on estimated cost (approx 200USD) above 80% of actual spend will trigger the alarm.

**Note:** the pricing is given based on mumbai region. calculate cost according to deployment aws region

## Security Measures

- **Private EC2 Instances**: Instances are deployed in private subnets with no public IPs.

- **Security Groups**:
  - ALB allows HTTPS (443) from the internet
  - EC2 allows traffic only from ALB

- **HTTPS Enabled**:
  - ACM certificate used for SSL termination
  - HTTP traffic redirected to HTTPS

- **EBS Encryption**:
  - Volumes are encrypted using a customer-managed KMS key with least privilaged policy

- **IAM Roles**:
  - EC2 instances uses Instance Profile for ssm and cloudwatch only

- **ALB Access Logs**:
  - Stored in S3 for auditing

- **No SSH Access**:
  - AWS SSM is used for secure instance access

  ## Scaling Strategy

- **Auto Scaling Group (ASG)**:
  - Minimum: 2 instances
  - Maximum: 4 instances
  - Desired: 2 instances

**Note:** The values above can be modified as per the requirement and workload.

- **Multi-AZ Deployment**:
  - Instances are distributed across multiple Availability Zones for resilience

- **Dynamic Scaling**:
  - CloudWatch alarms monitor CPU utilization
  - Scale-out triggered when CPU usage is high
  - Scale-in when usage is low

- **Load Balancing**:
  - ALB distributes incoming traffic evenly across instances

This solution ensures the production system can handle varying traffic loads while maintaining high availability. Also flexible to deploy different application according to infra requirements because of reusability of terraform structure.

