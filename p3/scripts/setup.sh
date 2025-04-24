#!/bin/bash

echo "Make sure you run this script as root"
echo "Do you want to install all the dependencies? (y/n)"
read answer

if [ "$answer" != "${answer#[Yy]}" ]; then
    echo "Installing dependencies..."
else
    echo "Exiting"
    exit 1
fi

####### Install Docker #######
echo "Installing Docker..."
if ! command -v docker &>/dev/null; then
    sudo apt update || true
    sudo apt install -y docker.io || true
    sudo systemctl start docker || true
    sudo systemctl enable docker || true
    sudo groupadd docker || true
    sudo usermod -aG docker $USER || true
    newgrp docker || true
else
    echo "Docker is already installed."
fi

####### Install Curl #######
echo "Installing Curl..."
if ! command -v curl &>/dev/null; then
    sudo apt install -y curl || true
else
    echo "Curl is already installed."
fi

####### Install K3d #######
echo "Installing K3d..."
if ! command -v k3d &>/dev/null; then
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash || true
else
    echo "K3d is already installed."
fi

####### Install Kubectl #######
echo "Installing Kubectl..."
if ! command -v kubectl &>/dev/null; then
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" || true
    sudo chmod +x kubectl || true
    sudo mv kubectl /bin/ || true
else
    echo "Kubectl is already installed."
fi

##### Make First Cluster #####
echo "Creating K3d cluster..."
if ! k3d cluster list | grep -q "dev-cluster"; then
    k3d cluster create dev-cluster --port 8080:80@loadbalancer --port 8443:443@loadbalancer || true
else
    echo "Cluster 'dev-cluster' already exists."
fi

# Ensure kubectl command runs safely
echo "Applying Kubernetes configurations..."
kubectl apply || true

echo "Script completed!"

