#!/bin/bash

# Update the system
echo "Updating the system..."
sudo apt update && sudo apt upgrade -y

# Install Docker
echo "Installing Docker..."
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update && sudo apt install -y docker-ce docker-ce-cli containerd.io

# Install Docker Compose
echo "Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Create directories for Nexus
echo "Creating directories for Nexus data..."
sudo mkdir -p /opt/nexus-data
sudo chmod -R 200 /opt/nexus-data

# Pull and run the Nexus container
echo "Deploying Nexus..."
docker run -d -p 8081:8081 --name nexus \
  --restart unless-stopped \
  -v /opt/nexus-data:/nexus-data \
  sonatype/nexus3

# Set up a firewall
echo "Configuring firewall..."
sudo ufw allow OpenSSH
sudo ufw allow 8081
sudo ufw enable -y

# Output admin password
echo "Retrieving Nexus admin password..."
docker exec nexus cat /nexus-data/admin.password

echo "Deployment complete! Access Nexus at http://<your-droplet-ip>:8081"
