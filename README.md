# Celo Org Reusable Workflows (`v3.0.0`)

This repository provides **reusable GitHub Actions workflows** for common CI/CD tasks:

- Docker image builds
- Go test automation
- NPM package publishing
- OpenSSF Scorecard checks
- Terraform operations

These workflows are designed to meet the requirements of https://slsa.dev/spec/v1.1/levels when used to build artifacts such as container images or NPM packages.

---

## Usage

To use these workflows in your own repository, reference them via `workflow_call`:

```yaml
jobs:
  example:
    uses: celo-org/reusable-workflows/.github/workflows/<workflow-file>.yaml@v3.0.0  # e.g., docker-build.yaml
    with:
      # ...workflow inputs...
```

---

## Available Workflows

| Workflow File         | Description                               |
|------------------------|-------------------------------------------|
| `docker-build.yaml`    | Build and push Docker images              |
| `go-tests.yaml`        | Run Go tests, vet, and lint               |
| `npm-publish.yaml`     | Publish NPM packages using OpenVPN & Akeyless |
| `scorecard.yaml`       | Run OpenSSF Scorecard checks              |
| `terraform.yaml`       | Run Terraform plan and apply operations   |

---

## Workflows

### 1. Docker Build (`docker-build.yaml`)

Build and optionally push a Docker image.

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
      group: ${{ github.workflow }}-${{ github.head_ref || github.ref }}
      cancel-in-progress: true
    if: github.ref_name != github.event.repository.default_branch
    uses: celo-org/reusable-workflows/.github/workflows/docker-build.yaml@v3.0.0
    with:
      # Request these values from DevOps or Security if unsure
      workload-id-provider: projects/12345/locations/global/workloadIdentityPools/gh-pool-name/providers/github-by-repos
      service-account: my-svc-account@gcp-project.iam.gserviceaccount.com
      artifact-registry: us-west1-docker.pkg.dev/mycircle/myrepo
      tags: mytag
      context: .
      environment: development  # Only if using GitHub Environments: https://docs.github.com/en/actions/how-tos/writing-workflows/choosing-what-your-workflow-does/using-environments-for-deployment
      debug-enabled: ${{ inputs.debug != '' && inputs.debug || false }}
```

---

### 2. Go Tests (`go-tests.yaml`)

Run Go tests, vet, build, and lint.

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

---

### 3. NPM Publish (`npm-publish.yaml`)

Publish NPM packages. Uses **OpenVPN through GCP** and optionally **Akeyless** to securely manage secrets and restrict token access.

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
      group: ${{ github.workflow }}-${{ github.head_ref || github.ref }}
      cancel-in-progress: true
    uses: celo-org/reusable-workflows/.github/workflows/npm-publish.yaml@v3.0.0
    with:
      node-version: 20
      version-command: yarn versioning
      publish-command: yarn release
```

---

### 4. Scorecard (`scorecard.yaml`)

Run [OpenSSF Scorecard](https://github.com/ossf/scorecard) checks to assess repository security. This workflow **only works on public repositories**.

```yaml
jobs:
  analysis:
    permissions:
      id-token: write
      security-events: write
      actions: read
      contents: read
    concurrency:
      group: ${{ github.workflow }}-${{ github.head_ref || github.ref }}
      cancel-in-progress: true
    uses: celo-org/reusable-workflows/.github/workflows/scorecard.yaml@v3.0.0
```

---

### 5. Terraform Plan & Apply (`terraform.yaml`)

Run Terraform `plan` (on pull requests) and `apply` (on merges) using GCP/Akeyless integration. Supports **matrixed directories** for monorepos.

```yaml
jobs:
  Terraform-Plan:
    if: github.ref_name != github.event.repository.default_branch
    permissions: # Must change the job token permissions to use JWT auth
      contents: read
      id-token: write
      pull-requests: write
    concurrency:
      group: ${{ github.workflow }}-${{ matrix.dir }}-${{ github.head_ref || github.ref }}
      cancel-in-progress: true
    strategy:
      fail-fast: false
      matrix:
        dir: ["terraform-config/dir1", "terraform-config/dir2", "terraform-config/dir3"]
    uses: celo-org/reusable-workflows/.github/workflows/terraform.yaml@v3.0.0
    with:
      # Request these values from DevOps or Security if unsure
      working-dir: ${{ matrix.dir }}
      workload-id-provider: projects/12345/locations/global/workloadIdentityPools/gh-pool-name/providers/github-by-repos
      service-account: my-svc-account@gcp-project.iam.gserviceaccount.com
      akeyless-api-gateway: https://my-akeyless-gateway
      akeyless-github-access-id: p-my-access-id
      environment: development
      debug-enabled: ${{ inputs.debug != '' && inputs.debug || false }}

  Terraform-Apply:
    if: github.ref_name == github.event.repository.default_branch
    permissions: # Must change the job token permissions to use JWT auth
      contents: read
      id-token: write
      pull-requests: write
    concurrency:
      group: ${{ github.workflow }}-${{ matrix.dir }}-${{ github.head_ref || github.ref }}
      cancel-in-progress: true
    strategy:
      fail-fast: false
      matrix:
        dir: ["terraform-config/dir1", "terraform-config/dir2", "terraform-config/dir3"]
    uses: celo-org/reusable-workflows/.github/workflows/terraform.yaml@v3.0.0
    with:
      # Request these values from DevOps or Security if unsure
      working-dir: ${{ matrix.dir }}
      workload-id-provider: projects/12345/locations/global/workloadIdentityPools/gh-pool-name/providers/github-by-repos
      service-account: my-svc-account@gcp-project.iam.gserviceaccount.com
      akeyless-api-gateway: https://my-akeyless-gateway
      akeyless-github-access-id: p-my-access-id
      environment: production  # Optional: GitHub environment name
      debug-enabled: ${{ inputs.debug != '' && inputs.debug || false }}
```

---

> 🗂 For the most up-to-date list of workflows, [browse the `v3.0.0` branch](https://github.com/celo-org/reusable-workflows/tree/v3.0.0/.github/workflows).
