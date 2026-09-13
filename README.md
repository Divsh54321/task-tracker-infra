# Task Tracker Infra — Terraform (AWS)

Infrastructure as Code for the [Task Tracker API](https://github.com/<your-username>/task-tracker-api) project. This repo provisions the AWS EC2 instance and security group that host the API — no manual console clicks, no undocumented server setup.

This was built as Project 2 in a hands-on DevOps learning track, immediately after manually provisioning the same setup by hand in Project 1. The goal: replace "I clicked through the console and hope I remember what I did" with a reproducible, version-controlled definition of the infrastructure.

---

## What this provisions

- One **security group** (`task-tracker-sg`) allowing inbound SSH (22) and app traffic (8000), and all outbound traffic
- One **EC2 instance** (`task-tracker-server`) — Ubuntu 24.04 LTS, `t3.micro` (free-tier eligible in `ap-south-1`)
- Outputs the instance's **public IP** once created

---

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) installed
- AWS CLI configured (`aws configure`) with an IAM user's access key/secret — Terraform reads credentials from the same shared `~/.aws/credentials` file the CLI uses, so no extra credential setup is needed here
- An existing EC2 key pair (referenced by name in `main.tf` as `key_name`) — create one in the AWS Console under EC2 → Key Pairs if you don't have one

---

## Usage

```bash
terraform init      # downloads the AWS provider plugin (run once)
terraform plan       # preview what will be created/changed/destroyed
terraform apply      # actually create the resources (type 'yes' to confirm)
```

Once applied, the public IP is printed as an output. To tear everything down:

```bash
terraform destroy
```

---

## File structure

| File                  | Purpose                                              |
|-----------------------|-------------------------------------------------------|
| `provider.tf`         | Declares the AWS provider and region (`ap-south-1`)   |
| `security_group.tf`   | Firewall rules for SSH + app traffic                  |
| `main.tf`             | Looks up the latest Ubuntu 24.04 AMI and defines the EC2 instance |

---

## A debugging note, kept here on purpose

Two real issues came up while building this, worth documenting for anyone hitting the same thing:

1. **`t2.micro` is not free-tier eligible in every region.** In `ap-south-1` (Mumbai), the free-tier eligible type is `t3.micro`. Always verify with:
   ```bash
   aws ec2 describe-instance-types --filters "Name=free-tier-eligible,Values=true" --region <your-region> --query "InstanceTypes[*].InstanceType" --output table
   ```

2. **AMI name filters can go stale.** Canonical's naming convention shifted slightly for Ubuntu 24.04 ("Noble Numbat"). A filter that worked for 22.04 ("Jammy Jellyfish") didn't directly translate — the fix was loosening the filter pattern and adding a `virtualization-type = "hvm"` filter for precision instead of relying on an exact name match. When an AMI `data` source returns "no results," verify the actual naming pattern directly via the AWS CLI (`aws ec2 describe-images ...`) rather than guessing at the `.tf` filter blindly — and make sure you're searching under Canonical's official owner ID (`099720109477`), not your own account ID.

---

## State file — not committed

`terraform.tfstate` (Terraform's record of what it created) is deliberately excluded via `.gitignore`, since it can contain sensitive resource details and shouldn't live in version control for a real project. In a team setting, this would typically be stored remotely (e.g., an S3 backend) instead of locally.

---

## Project Status

- [x] Security group defined as code
- [x] EC2 instance defined as code, using a dynamic AMI lookup instead of a hardcoded ID
- [x] Verified against the existing CI/CD pipeline from Project 1 (re-pointed at the new instance's IP)
- [ ] Remote state backend (S3)
- [ ] Ansible for post-provisioning configuration (next project in this learning track)