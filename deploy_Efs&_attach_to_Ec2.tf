# Initialize provider
provider "aws" {
  region = "us-east-1" # Replace with your desired region
}

# Create a VPC
resource "aws_vpc" "example_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "example-vpc"
  }
}

# Create Subnets
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.example_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a" # Replace with your preferred AZ
  tags = {
    Name = "example-public-subnet"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.example_vpc.id
  tags = {
    Name = "example-igw"
  }
}

# Create Route Table for Public Subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.example_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "example-public-route-table"
  }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "public_rta" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Create a Security Group for EFS
resource "aws_security_group" "efs_sg" {
  vpc_id = aws_vpc.example_vpc.id
  name   = "efs-sg"

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "efs-security-group"
  }
}

# Create a Security Group for EC2
resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.example_vpc.id
  name   = "ec2-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Replace with your IP for security
  }

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    security_groups = [aws_security_group.efs_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-security-group"
  }
}

# Create an EFS File System
resource "aws_efs_file_system" "efs" {
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  performance_mode = "generalPurpose"

  tags = {
    Name = "example-efs"
  }
}

# Mount Target for EFS in Public Subnet
resource "aws_efs_mount_target" "efs_mt" {
  file_system_id = aws_efs_file_system.efs.id
  subnet_id      = aws_subnet.public_subnet.id
  security_groups = [
    aws_security_group.efs_sg.id
  ]
}

# Create an EC2 Instance
resource "aws_instance" "ec2_instance" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI in us-east-1
  instance_type = "t2.micro"

  subnet_id              = aws_subnet.public_subnet.id
  security_groups        = [aws_security_group.ec2_sg.name]

  tags = {
    Name = "example-ec2-instance"
  }

  user_data = <<-EOF
                #!/bin/bash
                sudo yum update -y
                sudo yum install -y amazon-efs-utils
                sudo mkdir -p /mnt/efs
                sudo mount -t efs ${aws_efs_file_system.efs.id}:/ /mnt/efs
                echo "${aws_efs_file_system.efs.id}:/ /mnt/efs efs defaults,_netdev 0 0" >> /etc/fstab
              EOF
}

# Output EFS and EC2 Details
output "efs_id" {
  value = aws_efs_file_system.efs.id
}

output "ec2_instance_public_ip" {
  value = aws_instance.ec2_instance.public_ip
}
