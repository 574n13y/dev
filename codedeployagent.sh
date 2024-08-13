#!/bin/bash
# This installs the CodeDeploy agent and its prerequisites on Ubuntu 22.04.

# Update the package list
sudo apt-get update 

# Install necessary packages
sudo apt-get install ruby-full ruby-webrick wget -y 

# Navigate to the /tmp directory
cd /tmp 

# Download the CodeDeploy agent .deb package
wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/releases/codedeploy-agent_1.3.2-1902_all.deb 

# Create a directory for the extracted .deb package
mkdir codedeploy-agent_1.3.2-1902_ubuntu22 

# Extract the .deb package
dpkg-deb -R codedeploy-agent_1.3.2-1902_all.deb codedeploy-agent_1.3.2-1902_ubuntu22 

# Modify the dependency list to match Ruby version
sed 's/Depends:.*/Depends: ruby-full/' -i ./codedeploy-agent_1.3.2-1902_ubuntu22/DEBIAN/control 

# Rebuild the .deb package
dpkg-deb -b codedeploy-agent_1.3.2-1902_ubuntu22/ 

# Install the CodeDeploy agent
sudo dpkg -i codedeploy-agent_1.3.2-1902_ubuntu22.deb 

# Check if the CodeDeploy agent service is running
systemctl list-units --type=service | grep codedeploy 

# Display the status of the CodeDeploy agent service
sudo service codedeploy-agent status
