# HCP Workspace Execution Mode Configuration

## Problem

When running `terraform refresh`, `terraform plan`, or `terraform apply`, Terraform is executing in HCP's cloud environment (remote execution), which cannot access your internal DNS names like `unifi.mgmt.specterrealm.com`.

## Root Cause

Your HCP workspace `homelab-unifi` is configured with **Remote Execution Mode**, which means:

- All Terraform operations run in HCP's cloud
- Cannot access internal/private DNS names
- Cannot access resources behind your firewall

## Solution: Change to Local Execution Mode

### Step 1: Access Workspace Settings

1. Go to: https://app.terraform.io/app/SpecterRealm/homelab-unifi/settings/general
2. Or navigate: HCP → Workspaces → `homelab-unifi` → Settings → General

### Step 2: Change Execution Mode

1. Find the **"Execution Mode"** section
2. Change from **"Remote"** to **"Local"**
3. Click **"Save settings"**

### Step 3: Verify

After changing to Local execution mode:

```bash
# This should now run locally (on your machine)
terraform plan

# This should also run locally
terraform apply

# This should also run locally
terraform refresh
```

## What Changes?

**Before (Remote Execution):**

- ✅ State stored in HCP
- ❌ Commands run in HCP cloud
- ❌ Cannot access internal APIs

**After (Local Execution):**

- ✅ State stored in HCP (unchanged)
- ✅ Commands run on your machine
- ✅ Can access internal APIs

## Benefits of Local Execution Mode

1. **Access to Internal Resources**: Can reach `unifi.mgmt.specterrealm.com`
2. **Faster Execution**: No network latency to HCP
3. **Better Debugging**: Full access to local tools and logs
4. **State Still Remote**: State is still stored securely in HCP

## Alternative: Keep Remote but Use Remote Agents

If you want to keep remote execution, you would need to:

1. Set up a Terraform agent in your network
2. Configure the workspace to use that agent
3. The agent would run in your network and have access to internal DNS

But for most use cases, **Local execution mode is simpler and better**.

## Verification

After changing to Local execution mode, test with:

```bash
cd /Users/michaelheaton/Projects/HomeLab/unifi/terraform
terraform plan
```

You should see:

- No "Running apply in HCP Terraform" message
- No "Preparing the remote apply" message
- Commands execute directly on your machine
- Can successfully connect to UniFi API
