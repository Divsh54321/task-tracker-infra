data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/*noble*24.04*amd64*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "task_tracker_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  key_name               = "task-tracker-key"
  vpc_security_group_ids = [aws_security_group.task_tracker_sg.id]

  tags = {
    Name    = "task-tracker-server"
    Project = "task-tracker"
  }
}

output "public_ip" {
  value = aws_instance.task_tracker_server.public_ip
}