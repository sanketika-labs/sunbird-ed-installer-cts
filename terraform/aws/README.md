# Sunbird ED AWS Installer

This directory contains Terraform and Terragrunt configurations for deploying Sunbird ED on AWS using EKS (Elastic Kubernetes Service).

## Architecture Overview

The installation creates the following AWS resources:

- **VPC**: Virtual Private Cloud with public and private subnets across 3 availability zones
- **EKS Cluster**: Managed Kubernetes cluster with auto-scaling node groups
- **S3 Buckets**: 
  - Public bucket for static assets
  - Private bucket for sensitive data
  - DIAL bucket for DIAL state
  - Velero bucket for backups
- **IAM Roles**: IRSA (IAM Roles for Service Accounts) for Sunbird and Velero
- **Load Balancers**: Network Load Balancers for public and private ingress
- **State Backend**: S3 bucket and DynamoDB table for Terraform state

## Prerequisites

### Required Tools

1. **AWS CLI** (>= 2.0)
   ```bash
   # Install AWS CLI
   curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
   unzip awscliv2.zip
   sudo ./aws/install
   
   # Configure AWS credentials
   aws configure
   ```

2. **Terraform** (>= 1.3)
   ```bash
   # Install Terraform
   wget https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip
   unzip terraform_1.6.6_linux_amd64.zip
   sudo mv terraform /usr/local/bin/
   ```

3. **Terragrunt** (>= 0.45)
   ```bash
   # Install Terragrunt
   wget https://github.com/gruntwork-io/terragrunt/releases/download/v0.54.8/terragrunt_linux_amd64
   chmod +x terragrunt_linux_amd64
   sudo mv terragrunt_linux_amd64 /usr/local/bin/terragrunt
   ```

4. **kubectl** (>= 1.28)
   ```bash
   # Install kubectl
   curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
   chmod +x kubectl
   sudo mv kubectl /usr/local/bin/
   ```

5. **helm** (>= 3.12)
   ```bash
   # Install Helm
   curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
   ```

6. **yq** (>= 4.0)
   ```bash
   # Install yq
   sudo wget -qO /usr/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
   sudo chmod +x /usr/bin/yq
   ```

7. **Python 3** and **pip**
   ```bash
   sudo apt-get update
   sudo apt-get install -y python3 python3-pip
   ```

8. **Newman** (Postman CLI)
   ```bash
   sudo npm install -g newman
   ```

### AWS IAM Permissions

Your AWS user/role needs the following permissions:
- EC2 (VPC, Subnets, Security Groups)
- EKS (Cluster, Node Groups)
- S3 (Bucket creation, Object operations)
- IAM (Role and Policy creation)
- DynamoDB (Table creation)
- Route53 (optional, for DNS management)
- CloudWatch Logs

You can use the `AdministratorAccess` policy for initial setup, but it's recommended to create a custom policy with minimum required permissions for production.

## Configuration

### Step 1: Copy Template Directory

```bash
cd terraform/aws
cp -r template my-environment
cd my-environment
```

### Step 2: Edit global-values.yaml

Update the following mandatory fields in `global-values.yaml`:

```yaml
global:
  building_block: "sunbird"              # Your building block name
  env: "prod"                            # Short environment name
  environment: "prod01"                  # 1-9 lowercase alphanumeric
  
  # AWS Configuration
  cloud_storage_region: "us-east-1"      # Your AWS region
  aws_account_id: "123456789012"         # Your AWS account ID
  
  # Domain
  domain: "sunbird.example.com"          # Your domain name
  
  # SSL Certificates (required)
  proxy_private_key: |
    -----BEGIN PRIVATE KEY-----
    <your-private-key>
    -----END PRIVATE KEY-----
  proxy_certificate: |
    -----BEGIN CERTIFICATE-----
    <your-certificate>
    -----END CERTIFICATE-----
  
  # Application Secrets
  sunbird_google_captcha_site_key: "your-site-key"
  google_captcha_private_key: "your-private-key"
  sunbird_google_oauth_clientId: "your-client-id"
  sunbird_google_oauth_clientSecret: "your-client-secret"
  mail_server_from_email: "noreply@example.com"
  mail_server_password: "your-sendgrid-api-key"
  youtube_apikey: "your-youtube-api-key"
```

### Optional Configurations

#### Using Existing VPC

```yaml
global:
  create_network: "false"
  vpc_id: "vpc-xxxxx"
  private_subnet_ids: ["subnet-xxxxx", "subnet-yyyyy"]
  public_subnet_ids: ["subnet-zzzzz", "subnet-aaaaa"]
```

#### Route53 DNS Management

```yaml
global:
  manage_dns: true
  route53_zone_id: "Z1234567890ABC"
```

#### External Database

```yaml
global:
  create_database: false
  external_db_host: "db.example.com"
  external_db_port: "5432"
  external_db_name: "sunbird"
```

## Installation

### Full Installation

Run the complete installation with:

```bash
./install.sh
```

This will:
1. Create S3 bucket and DynamoDB table for Terraform state
2. Backup existing kubeconfig
3. Create AWS infrastructure (VPC, EKS, S3, IAM)
4. Install Helm components (monitoring, edbb, learnbb, etc.)
5. Configure certificates
6. Setup DNS
7. Run post-installation tasks

### Step-by-Step Installation

For more control, run individual steps:

```bash
# 1. Create Terraform backend
./install.sh create_tf_backend
source tf.sh

# 2. Create AWS infrastructure
./install.sh create_tf_resources

# 3. Install Helm components
./install.sh install_helm_components

# 4. Configure DNS
./install.sh dns_mapping

# 5. Generate Postman environment
./install.sh generate_postman_env

# 6. Run post-install configuration
./install.sh run_post_install

# 7. Create client forms
./install.sh create_client_forms
```

## Module Deployment Order

Terragrunt automatically manages dependencies, but the deployment order is:

1. **network** → Creates VPC and subnets
2. **eks** → Creates EKS cluster
3. **storage** → Creates S3 buckets
4. **iam** → Creates IRSA roles (depends on EKS and storage)
5. **keys** → Generates JWT and RSA keys
6. **output-file** → Generates global-cloud-values.yaml
7. **upload-files** → Syncs artifacts to S3

## Accessing the Cluster

After installation, your kubeconfig is automatically updated:

```bash
# Verify cluster access
kubectl get nodes

# Get all pods
kubectl get pods -n sunbird

# Get services
kubectl get svc -n sunbird
```

## DNS Configuration

### Managed DNS (Route53)

If you set `manage_dns: true` in global-values.yaml, the installer automatically creates a CNAME record pointing to the Network Load Balancer.

### Manual DNS

If `manage_dns: false`, you need to manually create a CNAME record:

```
Type:  CNAME
Name:  sunbird.example.com
Value: <LoadBalancer-DNS-Name>
TTL:   300
```

Get the load balancer hostname:
```bash
kubectl get svc -n sunbird nginx-public-ingress-ingress-nginx-controller \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

## Verification

### Check Pod Status

```bash
kubectl get pods -n sunbird
```

All pods should be in `Running` or `Completed` state.

### Access Application

Open your browser and navigate to:
```
https://sunbird.example.com
```

Default credentials:
- **Keycloak Admin**: `admin` / `admin` (change after first login)
- **Grafana**: `admin` / `prom-operator`

## Monitoring

Access Grafana dashboards:

```bash
# Get Grafana URL
echo "https://$(kubectl get cm -n sunbird lms-env -ojsonpath='{.data.sunbird_web_url}')/grafana"
```

## Backup and Restore

Velero is automatically configured for backups:

```bash
# Create a backup
velero backup create my-backup --include-namespaces sunbird

# List backups
velero backup get

# Restore from backup
velero restore create --from-backup my-backup
```

Backups are stored in the Velero S3 bucket.

## Troubleshooting

### Check Terraform State

```bash
source tf.sh
terragrunt run-all output
```

### Check AWS Resources

```bash
# List EKS clusters
aws eks list-clusters --region us-east-1

# List S3 buckets
aws s3 ls | grep <environment-name>

# Check IAM roles
aws iam list-roles | grep <environment-name>
```

### Pod Issues

```bash
# Describe pod
kubectl describe pod <pod-name> -n sunbird

# View logs
kubectl logs <pod-name> -n sunbird

# Restart deployment
kubectl rollout restart deployment <deployment-name> -n sunbird
```

### DNS Not Resolving

```bash
# Check DNS propagation
dig sunbird.example.com

# Force DNS check
nslookup sunbird.example.com 8.8.8.8
```

## Updating Configuration

To update the deployment:

1. Edit `global-values.yaml` or `global-cloud-values.yaml`
2. Apply changes:
   ```bash
   source tf.sh
   terragrunt run-all apply
   ```
3. Restart affected pods:
   ```bash
   kubectl rollout restart deployment -n sunbird <deployment-name>
   ```

## Destroying Resources

⚠️ **WARNING**: This will delete all AWS resources and data!

```bash
./install.sh destroy_tf_resources
```

Or manually:
```bash
source tf.sh
terragrunt run-all destroy
```

## Cost Estimation

Approximate monthly costs for AWS resources:

| Resource | Configuration | Estimated Cost (USD/month) |
|----------|--------------|----------------------------|
| EKS Cluster | 1 cluster | $73 |
| EKS Nodes | 3x m5.2xlarge | $900 |
| NAT Gateway | 3 gateways | $100 |
| S3 Storage | 100 GB | $2 |
| S3 Requests | 1M requests | $1 |
| Load Balancers | 2 NLBs | $35 |
| **Total** | | **~$1,111/month** |

**Note**: Costs vary based on usage, region, and data transfer.

## Key Differences from GCP

| Aspect | GCP | AWS |
|--------|-----|-----|
| **Authentication** | Service Account Keys | IRSA (no key files) |
| **Storage** | GCS | S3 |
| **Registry** | GCR | ECR |
| **DNS** | Cloud DNS | Route53 |
| **Database** | Cloud SQL | RDS |
| **File Upload** | `gsutil cp` | `aws s3 cp` |
| **Load Balancer** | GCE LB | Network Load Balancer |

## Support

For issues and questions:
- GitHub Issues: [sunbird-ed-installer-fmps](https://github.com/vinodbhorge/sunbird-ed-installer-fmps)
- Documentation: Check `README.md` files in each module

## License

See [LICENSE](../../../LICENSE) file.
