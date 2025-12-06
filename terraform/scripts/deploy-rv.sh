#!/bin/bash
# Deploy RV Environment
# This script deploys the RV UniFi site configuration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "environments/rv/main.tf" ]; then
    print_error "Please run this script from the network directory"
    exit 1
fi

# Change to RV environment directory
cd environments/rv

print_status "Deploying RV environment..."

# Initialize Terraform
print_status "Initializing Terraform..."
terraform init

# Plan the deployment
print_status "Planning deployment..."
terraform plan

# Ask for confirmation
read -p "Do you want to apply these changes? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Applying changes..."
    terraform apply
    print_status "RV deployment completed successfully!"
else
    print_warning "Deployment cancelled by user"
    exit 0
fi




