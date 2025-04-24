#!/bin/bash

# Create a log file to capture all output
exec > >(tee /var/log/user-data.log) 2>&1

# --- Input Parameters ---
SECRET_NAME="${secret_name}"
REGION="${region}"

# --- Echo for Logging ---
echo "[INFO] Starting user-data script at $(date)"
echo "[INFO] Using SECRET_NAME: $SECRET_NAME"
echo "[INFO] Using REGION: $REGION"

# --- Remove old Docker versions ---
echo "[INFO] Removing old Docker packages..."
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do 
    sudo apt-get remove -y $pkg
done

# --- Update system and install dependencies ---
echo "[INFO] Updating system and installing dependencies..."
sudo apt update -y
sudo apt install -y ca-certificates curl gnupg lsb-release

# --- Set up Docker GPG key and repo ---
echo "[INFO] Setting up Docker GPG and repo..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc > /dev/null
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$${UBUNTU_CODENAME:-$${VERSION_CODENAME}}") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# --- Install Docker ---
echo "[INFO] Installing Docker..."
sudo apt update -y
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# --- Start and enable Docker ---
echo "[INFO] Starting Docker..."
sudo systemctl enable docker
sudo systemctl start docker

# --- Check Docker status ---
echo "[INFO] Docker service status:"
sudo systemctl status docker --no-pager

# --- Add ubuntu user to docker group ---
echo "[INFO] Adding user to docker group..."
sudo usermod -aG docker ubuntu

# --- Install jq and AWS CLI ---
echo "[INFO] Installing jq and AWS CLI..."
sudo apt install -y jq
sudo snap install aws-cli --classic

# --- Get secrets from AWS Secrets Manager ---
echo "[INFO] Fetching secrets from AWS Secrets Manager..."
SECRET_JSON=$(aws secretsmanager get-secret-value \
    --secret-id "$${SECRET_NAME}" \
    --region "$${REGION}" \
    --query SecretString \
    --output text)

# --- Export environment variables from secret ---
export DB_HOST=$(echo "$${SECRET_JSON}" | jq -r '.DB_HOST')
export DB_USER=$(echo "$${SECRET_JSON}" | jq -r '.DB_USER')
export DB_PASS=$(echo "$${SECRET_JSON}" | jq -r '.DB_PASS')
export DB_NAME=$(echo "$${SECRET_JSON}" | jq -r '.DB_NAME')

# --- Pull and run Docker container ---
echo "[INFO] Pulling and running Docker container..."
sudo docker pull michaelopp/teaser:latest

sudo docker run -d \
  --name teaser \
  -p 80:80 \
  -e DB_HOST="$${DB_HOST}" \
  -e DB_USER="$${DB_USER}" \
  -e DB_PASS="$${DB_PASS}" \
  -e DB_NAME="$${DB_NAME}" \
  michaelopp/teaser:latest

# --- Verify container is running ---
echo "[INFO] Docker containers running:"
sudo docker ps

echo "[INFO] User-data script complete at $(date)"
