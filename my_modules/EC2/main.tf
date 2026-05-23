resource "aws_instance" "my_ec2" {
  count                  = 2
  ami                    = "ami-0ec10929233384c7f"
  instance_type          = var.instance_type
  subnet_id              = var.public_subnets_ids[count.index]
  iam_instance_profile   = var.iam_instance_profile 
  vpc_security_group_ids = var.security_group_ec2 
  key_name               = var.key_name
  user_data = <<-EOF
  #!/bin/bash
  set -e
  exec > /var/log/user_data.log 2>&1

  echo "Starting user_data script..."

  # 1. Update system
  apt-get update -y
  apt-get upgrade -y

  # 2. Install dependencies
  apt-get install -y \
    curl \
    git \
    jq \
    ca-certificates \
    gnupg \
    unzip

  # 3. Install AWS CLI v2
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  ./aws/install
  rm -rf awscliv2.zip aws/

  echo "AWS CLI installed: $(aws --version)"

  # 4. Install Docker
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null

  apt-get update -y
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  # 5. Start Docker
  systemctl start docker
  systemctl enable docker
  usermod -aG docker ubuntu

  echo "Docker installed: $(docker --version)"

  # 6. Clone repo
  cd /home/ubuntu
  git clone https://github.com/Rohit-singh-gusain/movie-ticket-booking.git app
  cd app

  echo "Repo cloned successfully"

  # 7. Fetch backend secrets → create server/.env
  aws ssm get-parameter \
    --name "/quickshow/backend" \
    --with-decryption \
    --region us-east-1 \
    --query Parameter.Value \
    --output text | jq -r 'to_entries | .[] | "\(.key)=\(.value)"' \
    > /home/ubuntu/app/server/.env

  echo "Backend .env created"

  # 8. Fetch frontend secrets → create root .env
  aws ssm get-parameter \
    --name "/quickshow/frontend" \
    --with-decryption \
    --region us-east-1 \
    --query Parameter.Value \
    --output text | jq -r 'to_entries | .[] | "\(.key)=\(.value)"' \
    > /home/ubuntu/app/.env

  echo "Frontend .env created"

  # 9. Set correct permissions
  chown -R ubuntu:ubuntu /home/ubuntu/app

  # 10. Run docker compose
  cd /home/ubuntu/app
  docker compose -f docker-compose.yml up --build -d

  echo "Docker compose started successfully!"
  echo "user_data script completed!"
EOF

  tags = {
    Name = "quickshow-ec2-${count.index}"
  }
}

