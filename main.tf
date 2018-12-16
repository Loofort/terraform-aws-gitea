
module "vpc" {
  source = "./vpc"
  
  cidr = "10.0.0.0/16"
  cidr_subnet = "10.0.1.0/24"
  tags = "${var.tags}"
}

data "aws_ami" "al2" {
  owners      = ["amazon"]
  most_recent = true
  name_regex  = "^amzn2-ami-hvm-2.0.\\d+-x86_64-gp2$",
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.*"]
  }
}

resource "tls_private_key" "key" {
  algorithm   = "RSA"
  ecdsa_curve = "4096"
}
resource "aws_key_pair" "key" {
  public_key = "${tls_private_key.key.public_key_openssh}"
}
resource "aws_instance" "host" {
  ami                    = "${data.aws_ami.al2.id}"
  instance_type          = "t2.micro"
  subnet_id              = "${module.vpc.subnet}"
  key_name               = "${aws_key_pair.key.key_name}"
  vpc_security_group_ids = ["${aws_security_group.web.id}"]
  monitoring             = false # monitoring per 5 min for free (intead off 1 min payed)
  #iam_instance_profile   = "${var.iam_instance_profile}"
  user_data              = <<HEREDOC
  #!/bin/bash
  sudo yum update -y
  sudo amazon-linux-extras install docker
  sudo service docker start
  sudo usermod -a -G docker ec2-user

  sudo curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
HEREDOC

  associate_public_ip_address = true
  
  volume_tags            = "${var.tags}"
  tags                   = "${var.tags}"
  #root_block_device      = "${var.root_block_device}"
  #ebs_block_device       = "${var.ebs_block_device}"
  #ephemeral_block_device = "${var.ephemeral_block_device}"

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait",
      "mkdir ~/gitea",
    ]
  }
  provisioner "file" {
    source      = "docker-compose.yml"
    destination = "~/gitea/docker-compose.yml"
  }
  provisioner "remote-exec" {
    inline = [
      "cd ~/gitea/",
      "/usr/local/bin/docker-compose up -d",
    ]
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = "${tls_private_key.key.private_key_pem}"
  }
}

# Security Group
resource "aws_security_group" "web" {
  vpc_id      = "${module.vpc.id}"
  tags        = "${var.tags}"
  name        = "Gitea Server"
  description = "allows custom ssh and www"

  ingress {
    from_port = 3000
    to_port = 3000
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}