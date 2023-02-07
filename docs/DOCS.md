# Workflows List & Quickstart Guide

- [S3 Trunk Based Development](https://github.com/thomasmendez/workflows/blob/main/docs/s3_trunk_based_development.md) - Creates and deploys development, staging, and production environment infastructure for built SPA applications

Quickstart for [S3 Trunk Based Development](https://github.com/thomasmendez/workflows/blob/main/docs/s3_trunk_based_development.md) after completing requirements 

Example of Development CI Workflow ![Development.yml CI Workflow Example](https://github.com/thomasmendez/workflows/blob/main/docs/images/dev_deployment.png)

```yml
name: Development.yml CI
on:
  push:
    branches-ignore:
      - main

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