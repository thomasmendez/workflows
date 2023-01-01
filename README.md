# workflows
Github Action Workflows 

## Add Submodule



## Add to Workflow

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
      AWS_BUCKET_NAME: patts-dev
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
    needs: pre_build
    uses: thomasmendez/workflows/.github/workflows/s3_dev_deployment.yml@main
    with:
      AWS_BUCKET_NAME: ${{ needs.pre_build.outputs.AWS_BUCKET_NAME }}
      DIST_NAME: ${{ needs.pre_build.outputs.DIST_NAME }}
      DIST_PATH: ${{ needs.pre_build.outputs.DIST_PATH }}
    secrets:
      TF_API_TOKEN: ${{ secrets.TF_API_TOKEN }}
      AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY }}
      AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```