# How to Remove Resources from Terraform/UniFi

## ✅ Correct Way to Remove Resources

When you want to remove a resource (like a DNS record) from both Terraform and UniFi:

### Step 1: Remove from Terraform Configuration

Edit the configuration file (e.g., `dns-records.tf`) and delete the resource block:

```hcl
# DELETE this entire block:
resource "unifi_dns_record" "example" {
  name        = "example.specterrealm.com"
  record_type = "A"
  value       = "172.16.5.10"
  port        = 0
}
```

### Step 2: Verify with Plan

Run `terraform plan` to see what will be destroyed:

```bash
terraform plan
```

You should see:

```
Plan: 0 to add, 0 to change, 1 to destroy.
```

### Step 3: Apply the Changes

Run `terraform apply` to actually destroy the resource in UniFi:

```bash
terraform apply
```

Terraform will:

- Remove the resource from UniFi
- Remove it from Terraform state automatically

## ❌ Wrong Way (What We Did Initially)

**DO NOT** use `terraform state rm` to remove resources:

```bash
# ❌ DON'T DO THIS:
terraform state rm unifi_dns_record.example
```

**Why this is wrong:**

- Only removes from Terraform state
- Resource still exists in UniFi
- Creates drift between Terraform and reality
- You'll have to manually delete it in UniFi UI

## 📋 Complete Example: Removing a DNS Record

Let's say you want to remove `test-terraform.specterrealm.com`:

### 1. Find the resource in `dns-records.tf`:

```hcl
resource "unifi_dns_record" "test_terraform" {
  name        = "test-terraform.specterrealm.com"
  record_type = "A"
  value       = "192.168.1.99"
  port        = 0
}
```

### 2. Delete the entire resource block

### 3. Run plan:

```bash
terraform plan
```

Output:

```
Plan: 0 to add, 0 to change, 1 to destroy.

  # unifi_dns_record.test_terraform will be destroyed
  - resource "unifi_dns_record" "test_terraform" {
      - name        = "test-terraform.specterrealm.com" -> null
      - record_type = "A" -> null
      - value       = "192.168.1.99" -> null
      ...
    }
```

### 4. Apply:

```bash
terraform apply
```

Terraform will:

- ✅ Delete the DNS record from UniFi
- ✅ Remove it from Terraform state
- ✅ Your infrastructure now matches your config

## 🔄 What If Resource Was Already Removed from State?

If you accidentally used `terraform state rm` (like we did with Jenkins):

### Option 1: Re-import and Destroy (Recommended)

1. **Temporarily add the resource back to config**
2. **Import it**: `terraform import unifi_dns_record.example <id>`
3. **Remove from config again**
4. **Run plan** - should show it for destruction
5. **Apply** - will destroy it in UniFi

### Option 2: Manual Deletion

1. Delete the resource manually in UniFi UI
2. Remove from Terraform config (if still there)
3. State will be out of sync, but resource is gone

**Option 1 is preferred** because Terraform manages the full lifecycle.

## 📝 Quick Reference

| Action                    | Command              | When to Use               |
| ------------------------- | -------------------- | ------------------------- |
| Remove from config        | Edit `.tf` file      | Always - first step       |
| Check what will happen    | `terraform plan`     | Before applying           |
| Actually remove           | `terraform apply`    | After verifying plan      |
| ❌ Remove from state only | `terraform state rm` | **Never** - creates drift |

## 🎯 Key Principle

**Terraform should manage the full lifecycle:**

- Creating resources → `terraform apply`
- Updating resources → Edit config → `terraform apply`
- **Destroying resources → Remove from config → `terraform apply`**

Always let Terraform destroy resources - don't manually delete them or remove from state!
