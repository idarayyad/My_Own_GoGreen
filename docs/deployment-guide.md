# Deployment Guide for Go Green Insurance AWS Infrastructure

## Prerequisites

- AWS CLI installed and configured with appropriate credentials
- Terraform CLI installed (version 1.0.0 or later)
- Git installed

## Step 1: Clone the Repository

```bash
git clone https://github.com/your-org/go-green-insurance-aws.git
cd go-green-insurance-aws
```

## Step 2: Choose Your Environment

Navigate to the appropriate environment directory:

```bash
cd infrastructure/environments/dev  # or staging, or prod
```

## Step 3: Initialize Terraform

Initialize Terraform to download necessary providers and modules:

```bash
terraform init
```

## Step 4: Review and Modify Variables

Review the `terraform.tfvars` file in your chosen environment directory. Modify any variables as needed for your specific deployment.

## Step 5: Plan the Deployment

Generate and review an execution plan:

```bash
terraform plan -out=tfplan
```

Review the plan carefully to ensure it aligns with your expectations.

## Step 6: Apply the Changes

If the plan looks good, apply the changes:

```bash
terraform apply tfplan
```

## Step 7: Verify the Deployment

After the apply command completes:

1. Log into the AWS Console and verify that resources have been created as expected.
2. Check the outputs from Terraform for important information like load balancer URLs or database endpoints.

## Step 8: Clean Up (Optional)

If you need to tear down the infrastructure:

```bash
terraform destroy
```

**Warning:** This will destroy all resources managed by Terraform. Use with caution, especially in production environments.

## Troubleshooting

- If you encounter state lock issues: `terraform force-unlock [LOCK_ID]`
- For networking issues, ensure your AWS CLI is configured correctly and you have the necessary permissions.
- Check AWS CloudTrail logs for any API errors during resource creation.

## Updating the Infrastructure

To make changes to the infrastructure:

1. Modify the relevant `.tf` files in the `modules/` directory.
2. Run `terraform plan` to see the impact of your changes.
3. Apply the changes using `terraform apply`.

Always test changes in a non-production environment first.

## Backup and Disaster Recovery

- Terraform state is crucial. Ensure it's stored securely and backed up regularly.
- Consider using remote state storage like S3 with state locking via DynamoDB.

## Security Considerations

- Rotate AWS access keys regularly.
- Use AWS IAM roles for EC2 instances instead of hardcoded credentials.
- Regularly audit and update security group rules.

For any questions or issues, please contact the infrastructure team.
