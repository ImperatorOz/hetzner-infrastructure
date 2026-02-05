# ☁️ Hetzner Cloud Infrastructure Automation

This project demonstrates a production-grade **Infrastructure as Code (IaC)** workflow to provision cloud servers on Hetzner Cloud using **Terraform** and **GitHub Actions**.

It features a **Remote State** backend (HCP Terraform) to ensure state consistency between CI/CD pipelines and local development. This allows for automated deployment via GitHub and manual management (including destruction) via local terminal.

## 🏗 Architecture & Tech Stack

* **Cloud Provider:** [Hetzner Cloud](https://console.hetzner.cloud/)
* **Infrastructure as Code:** Terraform
* **State Management:** [HCP Terraform (Remote State)](https://app.terraform.io/)
* **CI/CD:** GitHub Actions
* **Compute:** `cax11` (Ampere® Altra® ARM64)
* **OS:** Ubuntu 22.04 LTS
* **Security:**
    * **State Locking:** Managed by Terraform Cloud to prevent conflicts.
    * **Secret Injection:** No secrets stored in files; injected via `TF_VAR_` environment variables.
    * **SSH Access:** Password-less authentication via public key injection.

---

## 🚀 Automated Deployment (CI/CD)

The GitHub Actions workflow is configured to automatically provision infrastructure on push. It connects to HCP Terraform to retrieve the state file, ensuring it knows about existing resources.

### 1. Setup (One-Time)
To enable the pipeline, you need to configure access for both Hetzner and Terraform Cloud.

Go to repository **Settings** → **Secrets and variables** → **Actions** and add these three secrets:

| Secret Name | Description |
| :--- | :--- |
| `HCLOUD_TOKEN` | Your Hetzner Cloud API Token (Read & Write permissions). |
| `SSH_PUBLIC_KEY` | The contents of your public SSH key (e.g., `cat ~/.ssh/id_ed25519.pub`). |
| `TF_API_TOKEN` | Your HCP Terraform User/Team Token (allows GitHub to read/write state). |

### 2. Deploy
Simply push a commit to the `main` branch. The action will:
1.  Authenticate with Terraform Cloud.
2.  Inject your secrets.
3.  Provision/Update the server.

---

## 💻 Local Development

Because we use Remote State, you can run Terraform locally and it will see the exact same infrastructure that GitHub built.

### 1. Prerequisites
* **Terraform CLI** installed.
* **HCP Terraform Account** (logged in via `terraform login`).

### 2. Create Local Config
Create a file named `dev.tfvars` in the root directory.
**Security Note:** Only put non-sensitive configuration here.

```hcl
# dev.tfvars
env         = "dev"
server_type = "cax11"

```

### 3. Inject Secrets (Environment Variables)

We do not save secrets to disk. Export them in your terminal session:

```bash
# 1. Hetzner Token
export TF_VAR_hcloud_token="hc_token_xxxxxxxxxxxxxxxxxxxx"

# 2. SSH Key
export TF_VAR_ssh_public_key=$(cat ~/.ssh/id_ed25519.pub)

```

### 4. Run Terraform

You can now run standard commands. Terraform will connect to the cloud backend automatically.

```bash
# Initialize (downloads providers and connects to remote state)
terraform init

# Plan
terraform plan -var-file=dev.tfvars

# Apply
terraform apply -var-file=dev.tfvars

```

---

## 🔌 Connecting to the Server

Once deployed, use the SSH key you injected to log in without a password:

```bash
ssh root@<SERVER_IP_ADDRESS>

```

*Note: If you recreated the server, you may need to run `ssh-keygen -R <IP>` to clear old host fingerprints.*

---

## 🧹 Cleaning Up (Destroy)

Because we are using **Remote State**, you can destroy the infrastructure locally even if it was created by GitHub Actions.

1. Ensure your environment variables are exported (see "Local Development" step 3).
2. Run the destroy command:

```bash
terraform destroy -var-file=dev.tfvars

```

This will remove the server from Hetzner and update the state file in the cloud.

---

## 📂 Project Structure

```text
.
├── .github/workflows
│   └── deploy.yml      # CI pipeline (Includes Remote State Auth)
├── .gitignore          # Blocks .tfstate, .tfvars, and crash logs
├── main.tf             # Resources & Cloud Backend configuration
├── variables.tf        # Variable definitions
├── README.md           # Documentation
└── dev.tfvars          # Local config only (NOT COMMITTED)

```