# Define the AWS provider
provider "aws" {
  region = "ap-south-1"  # Replace with your desired AWS region
}

# Define a security group
resource "aws_security_group" "example_sg" {
  name        = "example-sg"
  description = "Allow SSH and HTTP access"

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Replace with your IP range for security
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Replace with your IP range for security
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ExampleSecurityGroup"
  }
}

# Create an EC2 instance
resource "aws_instance" "example_instance" {
  ami           = "ami-0c02fb55956c7d316"  # Replace with an appropriate AMI ID for your region
  instance_type = "t2.micro"               # Replace with your desired instance type

  # Assign the security group
  vpc_security_group_ids = [aws_security_group.example_sg.id]

  # Key pair for SSH access
  key_name = "my-key-pair"  # Replace with the name of your existing key pair

  # Tags
  tags = {
    Name = "ExampleInstance"
  }

  # Optional: Root block device configuration
  root_block_device {
    volume_size = 8  # Size in GiB
    volume_type = "gp2"  # General Purpose SSD
  }
}

# Output the public IP address of the instance
output "instance_public_ip" {
  value = aws_instance.example_instance.public_ip
}
