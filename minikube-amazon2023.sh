# Update system
sudo dnf update -y

# Install required packages
sudo dnf install -y curl wget conntrack

# Install Docker
sudo dnf install -y docker

# Start Docker
sudo systemctl enable --now docker

# Add ec2-user to docker group
sudo usermod -aG docker ec2-user

# Download Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

# Install Minikube
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Check version
minikube version

# Download kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Make executable
chmod +x kubectl

# Install kubectl
sudo mv kubectl /usr/local/bin/

# Check version
kubectl version --client

# Log out and log back in (or run)
newgrp docker

# Start Minikube
minikube start --driver=docker
