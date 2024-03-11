data "aws_ami" "amazon-linux-2023" {
  owners      = [amazon]
  most_recent = true

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualication-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "ovner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-*-x86_64"]
  }
}

data "template_file" "userdata" {
  template = file("${abspath(path.module)}/userdata.sh")
  vars = {
    server-name = var.server_name
  }
}

resource "aws_instance" "tf_my_ec2" {
  ami                    = data.aws_ami.amazon-linux-2023.id
  instance_type          = var.instance_type
  count                  = var.num_of_instance
  key_name               = var.key_name
  vpc_security_group_ids = [data.aws_ami.amazon-linux-2023]
  user_data              = data.template_file.userdata.rendered
  tags = {
    name = var.tag
  }
}


resource "aws_security_group" "tf-sec-gr" {
  name = "${var.tag}-terraform-sec-grp"
  tags = {
    name = var.tag
  }

  dynamic "ingress" {
    for_each = var.docker-instance-ports
    iterator = ports
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress = {
    from_port   = 0
    protocol    = -1
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}


