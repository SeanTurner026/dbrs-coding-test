provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region     = "us-east-1"
}

data "aws_iam_policy" "ec2-full-access" {
    arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_policy_attachment" "ec2-full-access-policy-attach" {
    name = "ec2-full-access"
    users = [
        "sean.turner026@gmail.com"
    ]
    policy_arn = "${data.aws_iam_policy.ec2-full-access.arn}"
}

data "aws_ami" "ubuntu-jupyter-server-ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical

  depends_on = [
      "aws_iam_policy_attachment.ec2-full-access-policy-attach"
  ]
}

resource "aws_security_group" "jupyter-server-security-group" {
    name        = "jupyter_server_security"
    description = "Allow inbound traffic on ports 8888 (jupyter) and 22 (ssh)"

    ingress {
        from_port   = 8888
        to_port     = 8888
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    depends_on = [
        "aws_iam_policy_attachment.ec2-full-access-policy-attach"
    ]
}

resource "aws_key_pair" "sean-key" {
    key_name   = "sean-key"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIypZD01LV89GUQ6zSwAg6lq9XyD3ZS2CR5nWkS0vsel187Zu4tqFt4cO7f0mY9bTUrwRGEAhoxBIWMIYok8/ibZLeyZ7pMQei4z6xf0QhfkWdcMFPiZZJiz/W+u7XawayK1T76l9xWM0Q1vsWRk/pjCtDNBiFE7isbpDBSXXsJ6cQ7DW8YSKsykt7trl+ZmkTvA9g9EFfYOGtpEeoIBkXbi8twO6K9TkbgMkLebk9xupmmX4UM8fsEReGMFAWisbloDw4URRotn/XqW6m+vSCS7q/JAfUfsGcebOZNXBW7uYONgc45jznnY5ymZQ4iHo+VcJs+zjGzXvVDy73kTIX aws_terraform_ssh_key"

    depends_on = [
        "aws_iam_policy_attachment.ec2-full-access-policy-attach"
    ]
}

resource "aws_instance" "ubuntu-jupyter-server" {
    ami = "${data.aws_ami.ubuntu-jupyter-server-ami.id}"
    instance_type = "t2.medium"
    key_name      = "sean-key"

    security_groups = [
        "${aws_security_group.jupyter-server-security-group.name}",
    ]

    associate_public_ip_address = true

    depends_on = [
        "aws_key_pair.sean-key",
        "aws_security_group.jupyter-server-security-group"
    ]
  }

output "ec2-ip-address" {
    description = "Public IP assigned to EC2 instance"
    value = "${aws_instance.ubuntu-jupyter-server.public_ip}"
}

output "public-dns-address" {
    description = "Public DNS name assigned to the instance"
    value = "${aws_instance.ubuntu-jupyter-server.public_dns}"
}
