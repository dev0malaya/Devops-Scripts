vi kops.sh

#!/bin/bash

set -e

# -------------------------------
# Variables
# -------------------------------
BUCKET_NAME="loki-kops-testbkt420.k8s.local"
CLUSTER_NAME="loki.k8s.local"
REGION="ap-south-1"
ZONES="ap-south-1a,ap-south-1b"

CONTROL_PLANE_SIZE="m7i-flex.large"
NODE_SIZE="m7i-flex.large"

CONTROL_PLANE_COUNT=1
NODE_COUNT=2

CONTROL_PLANE_VOLUME=40
NODE_VOLUME=40

AMI_ID="ami-0f918f7e67a3323f0"

# -------------------------------
# Update PATH
# -------------------------------
echo 'export PATH=$PATH:/usr/local/bin' >> ~/.bashrc
source ~/.bashrc

# -------------------------------
# Generate SSH Key if not exists
# -------------------------------
if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa
fi

cp ~/.ssh/id_rsa.pub my-keypair.pub

# Safer permission than 777
chmod 644 my-keypair.pub

# -------------------------------
# Install kubectl
# -------------------------------
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# -------------------------------
# Install kops
# -------------------------------
wget https://github.com/kubernetes/kops/releases/download/v1.32.0/kops-linux-amd64

chmod +x kops-linux-amd64
sudo mv kops-linux-amd64 /usr/local/bin/kops

# -------------------------------
# Create S3 Bucket
# -------------------------------
aws s3api create-bucket \
  --bucket ${BUCKET_NAME} \
  --region ${REGION} \
  --create-bucket-configuration LocationConstraint=${REGION} || true

# -------------------------------
# Enable Versioning
# -------------------------------
aws s3api put-bucket-versioning \
  --bucket ${BUCKET_NAME} \
  --region ${REGION} \
  --versioning-configuration Status=Enabled

# -------------------------------
# Export KOPS State Store
# -------------------------------
export KOPS_STATE_STORE=s3://${BUCKET_NAME}

echo "export KOPS_STATE_STORE=s3://${BUCKET_NAME}" >> ~/.bashrc

# -------------------------------
# Create Cluster
# -------------------------------
kops create cluster \
  --name=${CLUSTER_NAME} \
  --zones=${ZONES} \
  --control-plane-count=${CONTROL_PLANE_COUNT} \
  --control-plane-size=${CONTROL_PLANE_SIZE} \
  --node-count=${NODE_COUNT} \
  --node-size=${NODE_SIZE} \
  --node-volume-size=${NODE_VOLUME} \
  --control-plane-volume-size=${CONTROL_PLANE_VOLUME} \
  --ssh-public-key=my-keypair.pub \
  --image=${AMI_ID} \
  --networking=calico \
  --topology=public

# -------------------------------
# Deploy Cluster
# -------------------------------
kops update cluster \
  --name=${CLUSTER_NAME} \
  --yes \
  --admin

# -------------------------------
# Wait for Cluster
# -------------------------------
echo "Waiting for cluster validation..."

kops validate cluster --wait 15m

echo ""
echo "========================================"
echo "Cluster Created Successfully"
echo "========================================"















export KOPS_STATE_STORE=s3://loki-kops-testbkt420.k8s.local

kops delete cluster --name loki.k8s.local --yes






goggle gemini script
====================

#!/bin/bash

set -euo pipefail

# -------------------------------
# Variables
# -------------------------------
BUCKET_NAME="loki-kops-testbkt420.k8s.local"
CLUSTER_NAME="loki.k8s.local"
REGION="ap-south-1"
ZONES="ap-south-1a,ap-south-1b"

CONTROL_PLANE_SIZE="m7i-flex.large"
NODE_SIZE="m7i-flex.large"

CONTROL_PLANE_COUNT=1
NODE_COUNT=2

CONTROL_PLANE_VOLUME=40
NODE_VOLUME=40

# -------------------------------
# Environment Setup
# -------------------------------
export PATH=$PATH:/usr/local/bin

# -------------------------------
# Generate SSH Key if not exists
# -------------------------------
if [ ! -f ~/.ssh/id_rsa ]; then
    echo "Generating SSH Key pair..."
    ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa
fi

cp ~/.ssh/id_rsa.pub my-keypair.pub
chmod 644 my-keypair.pub

# -------------------------------
# Install kubectl
# -------------------------------
if ! command -v kubectl &> /dev/null; then
    echo "Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
fi

# -------------------------------
# Install kops
# -------------------------------
if ! command -v kops &> /dev/null; then
    echo "Installing kOps..."
    curl -LO "https://github.com/kubernetes/kops/releases/download/v1.32.0/kops-linux-amd64"
    chmod +x kops-linux-amd64
    sudo mv kops-linux-amd64 /usr/local/bin/kops
fi

# -------------------------------
# Create S3 Bucket & Enable Versioning
# -------------------------------
echo "Setting up S3 State Store bucket..."
if ! aws s3api head-bucket --bucket "${BUCKET_NAME}" 2>/dev/null; then
    aws s3api create-bucket \
      --bucket "${BUCKET_NAME}" \
      --region "${REGION}" \
      --create-bucket-configuration LocationConstraint="${REGION}"
fi

aws s3api put-bucket-versioning \
  --bucket "${BUCKET_NAME}" \
  --region "${REGION}" \
  --versioning-configuration Status=Enabled

# -------------------------------
# Export KOPS State Store
# -------------------------------
export KOPS_STATE_STORE=s3://${BUCKET_NAME}

grep -qF "KOPS_STATE_STORE" ~/.bashrc || echo "export KOPS_STATE_STORE=s3://${BUCKET_NAME}" >> ~/.bashrc

# -------------------------------
# Create Cluster Manifest
# -------------------------------
echo "Creating kOps cluster manifest..."
kops create cluster \
  --name=${CLUSTER_NAME} \
  --zones=${ZONES} \
  --control-plane-count=${CONTROL_PLANE_COUNT} \
  --control-plane-size=${CONTROL_PLANE_SIZE} \
  --node-count=${NODE_COUNT} \
  --node-size=${NODE_SIZE} \
  --node-volume-size=${NODE_VOLUME} \
  --control-plane-volume-size=${CONTROL_PLANE_VOLUME} \
  --ssh-public-key=my-keypair.pub \
  --networking=calico \
  --topology=public

# -------------------------------
# Deploy Cluster
# -------------------------------
echo "Applying cluster config to AWS..."
kops update cluster \
  --name=${CLUSTER_NAME} \
  --yes \
  --admin

# -------------------------------
# Wait for Cluster
# -------------------------------
echo "Waiting for cluster validation (this can take 5–10 minutes)..."

kops validate cluster --wait 15m

echo ""
echo "========================================"
echo " Cluster ${CLUSTER_NAME} Created Successfully!"
echo "========================================"