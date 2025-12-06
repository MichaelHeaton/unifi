# Terraform Command Execution Guide

## Overview

Your Terraform configuration uses **HCP Terraform Cloud** as the backend. This means:

- **State** is stored in HCP (cloud)
- **Execution** can be either local or remote

## The Problem

When Terraform runs in HCP's cloud environment (remote execution), it cannot access your internal DNS names like `unifi.mgmt.specterrealm.com`. This causes errors like:

```
Error: unable to determine API URL style: Get "https://unifi.mgmt.specterrealm.com": dial tcp: lookup unifi.mgmt.specterrealm.com on 10.184.0.2:53: no such host
```

## Solution: Force Local Execution

For commands that need to access the UniFi API, you must force **local execution** using environment variables.

## Command Reference

### ✅ Commands That Work Locally (Force Local Execution)

```bash
# Plan - forces local execution
TF_CLI_ARGS="-input=false" terraform plan

# Apply - forces local execution
TF_CLI_ARGS="-input=false" terraform apply

# Refresh - forces local execution
TF_CLI_ARGS="-input=false" terraform refresh

# Import - always runs locally
terraform import <resource> <id>
```

### ✅ Commands That Work Remotely (No API Access Needed)

```bash
# State operations - work remotely or locally
terraform state list
terraform state show <resource>
terraform state rm <resource>
terraform state mv <old> <new>

# Format and validate - work remotely
terraform fmt
terraform validate

# Workspace operations
terraform workspace list
terraform workspace select <name>
```

## Recommended Workflow

### For Daily Operations (with API access needed):

```bash
# 1. Format and validate (works remotely)
terraform fmt
terraform validate

# 2. Plan locally (needs API access)
TF_CLI_ARGS="-input=false" terraform plan

# 3. Apply locally (needs API access)
TF_CLI_ARGS="-input=false" terraform apply
```

### For State-Only Operations:

```bash
# These work fine remotely (no API access needed)
terraform state list
terraform state show unifi_network.storage
terraform state rm <resource>
terraform import <resource> <id>
```

## Environment Variable Method

You can also set this in your shell to make it persistent:

```bash
# Add to ~/.zshrc or ~/.bashrc
export TF_CLI_ARGS="-input=false"

# Then run normally
terraform plan    # Will run locally
terraform apply   # Will run locally
```

## Alternative: Use -backend-config

If you want more control, you can temporarily use a local backend for operations:

```bash
# Create a local backend config
cat > backend-local.tf <<EOF
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
EOF

# Use it temporarily, then switch back
```

But this is more complex and not recommended.

## Summary

**For operations needing UniFi API access:**

- Use `TF_CLI_ARGS="-input=false"` prefix
- Or set `export TF_CLI_ARGS="-input=false"` in your shell

**For state-only operations:**

- Run normally (works remotely)

**Best Practice:**

- Always use local execution for `plan` and `apply`
- State operations work either way
