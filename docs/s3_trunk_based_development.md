# Trunk Based Deployment S3 Buckets

These workflows allow you to automatically deploy your SPA build to an S3 bucket using the [Trunk-Based Development](https://trunkbaseddevelopment.com/) approach.

## Trunk-Based Deployment S3 Bucket Process

1. Create a feature branch from main
2. Push changes to feature branch
3. [s3_dev_deployment.yml](https://github.com/thomasmendez/workflows/blob/main/.github/workflows/s3_dev_deployment.yml) file will deploy a S3 bucket based on SPA build artifact
4. When merging feature branch to main, previous feature branch S3 bucket will be deleted with [s3_dev_deployment_cleanup.yml](https://github.com/thomasmendez/workflows/blob/main/.github/workflows/s3_dev_deployment_cleanup.yml) file
5. When merging feature branch to main, a staging S3 bucket will be deployed from the [s3_stg_deployment.yml](https://github.com/thomasmendez/workflows/blob/main/.github/workflows/s3_stg_deployment.yml) file
6. When ready to deploy changes to production, a manual action can be run with the [s3_prd_deployment.yml](https://github.com/thomasmendez/workflows/blob/main/.github/workflows/s3_prd_deployment.yml) file. A Cloudfront distribution is also created. It is possible to provide a subdomain set for the cloudfront distribution, e.g `my_sub_domain.domain_name.com` instead of `www.domain_name.com` if desired. 

## Requirements

### Cloud Accounts

- [AWS Account](https://aws.amazon.com/console/)
- [Terraform Cloud Account](https://cloud.hashicorp.com/products/terraform)

### Github Secrets

The following secrets are required for all workflow files:

- `TF_API_TOKEN` - Obtained from User Settings -> Tokens
- `AWS_ACCESS_KEY_ID` - Obtained from a IAM user
- `AWS_SECRET_ACCESS_KEY` - Obtained from a IAM user

## Quickstart Guide

### On Branch Push

Sample `on` event for triggering on branch push that is not main (feature branch)

```yml
name: Development.yml CI
on:
  push:
    branches-ignore:
      - main
```

### pre_build Job

Sample `pre_build` job template for creating variables and passing them to different jobs in the workflow. This will add `-dev-<branch-name>` to make the dev s3 bucket easily identifiable. Example `-dev-feature-name`

```yml
jobs:
  pre_build:
    runs-on: ubuntu-latest
    env:
      AWS_BUCKET_NAME: my-site-dev
      DIST_NAME: dist-dev
      DIST_PATH: dist/
    outputs:
      AWS_BUCKET_NAME: ${{ steps.bucket_name.outputs.bucket }}
      DIST_NAME: ${{ env.DIST_NAME }}
      DIST_PATH: ${{ env.DIST_PATH }}
    steps:
      - name: "Create bucket_name_suffix Output"
        id: bucket_name_suffix
        run: |
          suffix=$(echo ${{ github.ref_name }} | sed 's/\//-/')
          echo "suffix=$suffix" >> $GITHUB_OUTPUT

      - name: "Create bucket_name Output"
        id: bucket_name
        run: |
          bucket_name=$(echo ${{ env.AWS_BUCKET_NAME }}-${{ steps.bucket_name_suffix.outputs.suffix }})
          echo "bucket=$bucket_name" >> $GITHUB_OUTPUT
```

### build Job

Sample `build` job template for SPA (could use npm or yarn with React, Vue, etc)

```yml
jobs:
  build:
    runs-on: ubuntu-latest
    needs: pre_build
    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Use Node.js
        uses: actions/setup-node@v3
        with:
          node-version: latest

      - name: Install Packages
        run: yarn install --immutable

      - name: Build App
        run: yarn run build

      - name: Create dist Artifact
        uses: actions/upload-artifact@v3
        with:
          name: ${{ needs.pre_build.outputs.DIST_NAME }}
          path: ${{ needs.pre_build.outputs.DIST_PATH }}
          retention-days: 1
```

### deploy Job

Sample `deploy` job template

```yml
jobs:
  deploy:
    needs: [pre_build, build]
    uses: thomasmendez/workflows/.github/workflows/s3_dev_deployment.yml@main
    with:
      AWS_BUCKET_NAME: ${{ needs.pre_build.outputs.AWS_BUCKET_NAME }}
      DIST_NAME: ${{ needs.pre_build.outputs.DIST_NAME }}
      DIST_PATH: ${{ needs.pre_build.outputs.DIST_PATH }}
    secrets:
      TF_API_TOKEN: ${{ secrets.TF_API_TOKEN }}
      AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
      AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

## References

### Files & Recommended Events

- Development.yml CI - [s3_dev_deployment.yml](https://github.com/thomasmendez/workflows/blob/main/.github/workflows/s3_dev_deployment.yml)

Run and deploy S3 on feature branch only

```yml
name: Development.yml CI
on:
  push:
    branches-ignore:
      - main
```

Example of Development CI Workflow ![Development.yml CI Workflow Example](https://github.com/thomasmendez/workflows/blob/main/docs/images/s3_trunk_based_development.md)

- Development.yml Cleanup CI - [s3_dev_deployment_cleanup.yml](https://github.com/thomasmendez/workflows/blob/main/.github/workflows/s3_dev_deployment_cleanup.yml)

Run and destroy S3 bucket that had related feature branch merged in

```yml
name: Development.yml Cleanup CI
on:
  pull_request:
    types: [closed]
```

Example of Development CI Cleanup Workflow ![Development.yml Cleanup CI Workflow Example](https://github.com/thomasmendez/workflows/blob/main/docs/images/dev_deployment_cleanup.png)

- Staging.yml CI - [s3_stg_deployment.yml](https://github.com/thomasmendez/workflows/blob/main/.github/workflows/s3_stg_deployment.yml)

Run and deploy S3 bucket to a stg environment when merge is pushed to `main`

```yml
name: Staging.yml CI
on:
  push:
    branches:
      - main
```

Example of Staging CI Cleanup Workflow ![Staging.yml CI Workflow Example](https://github.com/thomasmendez/workflows/blob/main/docs/images/stg_deployment.png)

- Production.yml CI - [s3_prd_deployment.yml](https://github.com/thomasmendez/workflows/blob/main/.github/workflows/s3_prd_deployment.yml)

Run on manual click in Action -> `Production.yml CI` -> `Run workflow` from `Branch: main`

```yml
name: Production.yml CI
on: workflow_dispatch
```
### Inputs

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
