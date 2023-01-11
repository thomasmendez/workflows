# Github Action Workflows

- [S3 Trunk Based Development](https://github.com/thomasmendez/workflows/blob/main/docs/s3_trunk_based_development.md) - Creates and deploys development, staging, and production environment infastructure for built SPA applications

## How to Setup

### Create Submodule at Desired Repo

*Note: Certain workflows may require the use of files in this repository*

`git submodule add https://github.com/thomasmendez/workflows.git`

### Set Workflow to Use

Create a job that uses the workflow file. It can be similar to the one below. You can find specifc examples in the [docs](https://github.com/thomasmendez/workflows/tree/main/docs/DOCS.md) folder

```yml
build:
  needs: pre_build
  uses: thomasmendez/workflows/.github/workflows/<workflow_file>.yml@main
  with:
    AWS_BUCKET_NAME: ${{ needs.pre_build.outputs.AWS_BUCKET_NAME }}
    DIST_NAME: ${{ needs.pre_build.outputs.DIST_NAME }}
    DIST_PATH: ${{ needs.pre_build.outputs.DIST_PATH }}
  secrets:
    TF_API_TOKEN: ${{ secrets.TF_API_TOKEN }}
    AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
    AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```
