# Trunk Based Deployment S3 Buckets

These workflows allow you to automatically deploy your SPA build to an S3 bucket using the [Trunk-Based Development](https://trunkbaseddevelopment.com/) approach.

## Trunk-Based Deployment S3 Bucket Process

1. Create a feature branch from main
2. Push changes to feature branch
3. [s3_dev_deployment.yml](https://github.com/thomasmendez/workflows/blob/main/.github/workflows/s3_dev_deployment.yml) file will deploy a S3 bucket based on SPA build artifact
4. When merging feature branch to main, previous feature branch S3 bucket will be deleted with [s3_dev_deployment_cleanup.yml](https://github.com/thomasmendez/workflows/blob/main/.github/workflows/s3_dev_deployment_cleanup.yml) file
5. When merging feature branch to main, a staging S3 bucket will be deployed from the [s3_stg_deployment.yml](https://github.com/thomasmendez/workflows/blob/main/.github/workflows/s3_stg_deployment.yml) file
6. When ready to deploy changes to production, a manual action can be run with the [s3_prd_deployment.yml](https://github.com/thomasmendez/workflows/blob/main/.github/workflows/s3_prd_deployment.yml) file. A Cloudfront distribution is also created. It is possible to provide a subdomain set for the cloudfront distribution, e.g `my_sub_domain.domain_name.com` insated of `www.domain_name.com` if desired. 

## Requirements

### Cloud Accounts

- [AWS Account](https://aws.amazon.com/console/)
- [Terraform Cloud Account](https://cloud.hashicorp.com/products/terraform)

### Github Secrets

The following secrets are required for all workflow files:

- `TF_API_TOKEN` - Obtained from User Settings -> Tokens
- `AWS_ACCESS_KEY_ID` - Obtained from a IAM user
- `AWS_SECRET_ACCESS_KEY` - Obtained from a IAM user

## Inputs Reference

```yml
AWS_BUCKET_NAME:
  description: 'The name of the AWS bucket'
  required: true
  type: string
AWS_REGION:
  description: 'The region where the AWS bucket will be deployed to'
  default: 'us-east-2'
  required: false
  type: string
DIST_NAME:
  description: 'The name of the distribution'
  required: true
  type: string
DIST_PATH:
  description: 'The name of the distribution path where build is located'
  required: true
  type: string
DOMAIN:
  description: 'The domain name of the distribution'
  required: true
  type: string
SUB_DOMAIN:
  description: 'The sub domain name of the distribution'
  required: false
  type: string
```

## Files Reference

- [s3_dev_deployment.yml](https://github.com/thomasmendez/workflows/blob/main/.github/workflows/s3_dev_deployment.yml)
- [s3_dev_deployment_cleanup.yml](https://github.com/thomasmendez/workflows/blob/main/.github/workflows/s3_dev_deployment_cleanup.yml)
- [s3_stg_deployment.yml](https://github.com/thomasmendez/workflows/blob/main/.github/workflows/s3_stg_deployment.yml)
- [s3_prd_deployment.yml](https://github.com/thomasmendez/workflows/blob/main/.github/workflows/s3_prd_deployment.yml)