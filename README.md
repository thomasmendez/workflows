# workflows

Github Action Workflows

## How to Setup

### Create Submodule at Desired Repo

`git submodule add https://github.com/thomasmendez/workflows.git`

### Set Workflow to Use

Create a job that uses the workflow file. It can be similar to the one below.

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
