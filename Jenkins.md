# The Instructions to Install Jenkins on an EC2 Instance Running Ubuntu

## Step 1: Update Your System & Install Java

```bash
sudo apt update
sudo apt install openjdk-*-jre
```

### Validate Installation

To ensure Java is installed correctly, check the version:

```bash
java -version
```

The output should look something like this:

```
openjdk version "11.0.12" 2021-07-20
OpenJDK Runtime Environment (build 11.0.12+7-post-Debian-2)
OpenJDK 64-Bit Server VM (build 11.0.12+7-post-Debian-2, mixed mode, sharing)
```

## Step 2: Install Jenkins

Copy and paste the following commands into your terminal to install Jenkins:

```bash
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null 
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update 
sudo apt-get install jenkins
```

## Step 3: Start Jenkins

To start and enable Jenkins to run at boot, use these commands:

```bash
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins
```

## Step 4: Open Port 8080 from AWS Console

Make sure to open port 8080 in your AWS Security Group settings to allow access to Jenkins.
