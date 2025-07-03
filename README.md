# Celo Org Reusable Workflows (`v3.0.0`)

This repository provides reusable GitHub Actions workflows for CI/CD tasks such as Docker image builds, Go test automation, npm publishing, security scorecard checks, and Terraform operations.
Using these workflows to build artifacts (container images or NPM packages) should meet all requirements for SLSA level 3 https://slsa.dev/

## Usage

To use these workflows in your own repository, call them via `workflow_call`:

```yaml
jobs:
  example:
    uses: celo-org/reusable-workflows/.github/workflows/<workflow-file>.yaml@v3.0.0
    with:
      # ...workflow inputs...
```

## Workflows

### 1. Docker Build (`docker-build.yaml`)
Build and optionally push a Docker image.

**Example:**
```yaml
jobs:
  Build-Container:
    permissions:
      actions: read
      contents: write
      pull-requests: write
      security-events: write
      attestations: write
      id-token: write
    concurrency:
      group:   ${{ github.workflow }}-${{ github.head_ref || github.ref }}
      cancel-in-progress: true
    if: github.ref_name != github.event.repository.default_branch
    uses: celo-org/reusable-workflows/.github/workflows/docker-build.yaml@v3.0.0
    with:
      workload-id-provider: projects/12345/locations/global/workloadIdentityPools/gh-pool-name/providers/github-by-repos # If unsure request from Devops/Security
      service-account: my-svc-account@gcp-project.iam.gserviceaccount.com
      artifact-registry: us-west1-docker.pkg.dev/mycircle/myrepo # If unsure request from Devops/Security
      tags: mytag
      context: .
      environment: development      # Only if using github environments: https://docs.github.com/en/actions/how-tos/writing-workflows/choosing-what-your-workflow-does/using-environments-for-deployment
      debug-enabled: ${{ inputs.debug != '' && inputs.debug || false }}

```

### 2. Go Tests (`go-tests.yaml`)
Run Go tests, build, vet, and lint.

**Example:**
```yaml
jobs:
  Go-Tests:
    uses: celo-org/reusable-workflows/.github/workflows/go-tests.yaml@v3.0.0
    permissions:
      contents: read
      id-token: write
      pull-requests: read
    with:
      path: "./path/to/tests"
      go-version: "1.22"
      warn-only: true
```

### 3. NPM Publish (`npm-publish.yaml`)
Publish npm packages, optionally using Akeyless for secrets.  Uses OpenVPN through GCP to restrict token access

**Example:**
```yaml
jobs:
  openvpn:
    permissions:
      contents: write
      actions: read
      pull-requests: write
      security-events: write
      attestations: write
      id-token: write
      repository-projects: write
    concurrency:
      group:   ${{ github.workflow }}-${{ github.head_ref || github.ref }}
      cancel-in-progress: true
    uses: celo-org/reusable-workflows/.github/workflows/npm-publish.yaml@v3.0.0
    with:
      node-version: 20
      version-command: yarn versioning
      publish-command: yarn release
```

### 4. Scorecard (`scorecard.yaml`)
Run OpenSSF Scorecard checks for repository security.  This only works on public repositories

**Example:**
```yaml
jobs:
  analysis:
    permissions:
      id-token: write
      security-events: write
      actions: read
      contents: read
    concurrency:
      group:   ${{ github.workflow }}-${{ github.head_ref || github.ref }}
      cancel-in-progress: true
    uses: celo-org/reusable-workflows/.github/workflows/scorecard.yaml@v3.0.0
```

### 5. Terraform Plan & Apply (`terraform.yaml`)
Run Terraform plan and apply with GCP/Akeyless integration.  Requires running for both a PR (plan), and merge (apply) so 2 entries needed.  This supports multiple directories with matrix

**Example:**
```yaml
jobs:
  Terraform-Plan:
    if: github.ref_name != github.event.repository.default_branch
    permissions: # Must change the job token permissions to use JWT auth
      contents: read
      id-token: write
      pull-requests: write
    concurrency:
      group:   ${{ github.workflow }}-${{ matrix.dir }}-${{ github.head_ref || github.ref }}
      cancel-in-progress: true
    strategy:
      fail-fast: false
      matrix:
        dir: ["terraform-config/dir1","terraform-config/dir2","terraform-config/dir3"]
    uses: celo-org/reusable-workflows/.github/workflows/terraform.yaml@v3.0.0
    with:
      working-dir: ${{ matrix.dir }}
      workload-id-provider: projects/12345/locations/global/workloadIdentityPools/gh-pool-name/providers/github-by-repos # If unsure request from Devops/Security
      service-account: my-svc-account@gcp-project.iam.gserviceaccount.com # If unsure request from Devops/Security
      akeyless-api-gateway: https://my-akeyless-gateway # If unsure request from Devops/Security
      akeyless-github-access-id: p-my-access-id # If unsure request from Devops/Security
      environment: development # optional for github development environments
      debug-enabled: ${{ inputs.debug != '' && inputs.debug || false }}

  Terraform-Apply:
    if: github.ref_name == github.event.repository.default_branch
    permissions: # Must change the job token permissions to use JWT auth
      contents: read
      id-token: write
      pull-requests: write
    concurrency:
      group:   ${{ github.workflow }}-${{ matrix.dir }}-${{ github.head_ref || github.ref }}
      cancel-in-progress: true
    strategy:
      fail-fast: false
      matrix:
        dir: ["terraform-config/dir1","terraform-config/dir2","terraform-config/dir3"]
    uses: celo-org/reusable-workflows/.github/workflows/terraform.yaml@v3.0.0
    with:
      working-dir: ${{ matrix.dir }}
      workload-id-provider: projects/12345/locations/global/workloadIdentityPools/gh-pool-name/providers/github-by-repos # If unsure request from Devops/Security
      service-account: my-svc-account@gcp-project.iam.gserviceaccount.com # If unsure request from Devops/Security
      akeyless-api-gateway: https://my-akeyless-gateway # If unsure request from Devops/Security
      akeyless-github-access-id: p-my-access-id # If unsure request from Devops/Security
      environment: production   #options for github development environments
      debug-enabled: ${{ inputs.debug != '' && inputs.debug || false }}
```

---

> For the most up-to-date list of workflows, [browse the v3.0.0 branch](https://github.com/celo-org/reusable-workflows/tree/v3.0.0/.github/workflows).
