provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow inbound SSH traffic"

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_web" {
    name = "allow_web"
    description = "Allow inbound web traffic"

    ingress {
        description = "HTTP from anywhere"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "HTTPS from anywhere"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "allow_mysql" {
    name = "allow_mysql"
    description = "Allow use of mysql connection"

    ingress {
        description = "Mysql from anywhere"
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "frontend_server" {
  ami           = "ami-010e83f579f15bba0"
  instance_type = "t2.micro"
  key_name      = "cosc349-2024"

  vpc_security_group_ids = [aws_security_group.allow_ssh.id, aws_security_group.allow_web.id]

  user_data = templatefile("${path.module}/build-frontendserver-vm.tpl", { mysql_server_ip = aws_db_instance.mysql_rds.address })

  tags = {
    Name = "FrontendServer"
  }
}

resource "aws_instance" "backend_server" {
  ami           = "ami-010e83f579f15bba0"
  instance_type = "t2.micro"
  key_name      = "cosc349-2024"

  vpc_security_group_ids = [
    aws_security_group.allow_ssh.id,
    aws_security_group.allow_web.id
  ]

  user_data = templatefile("${path.module}/build-backendserver-vm.tpl", { mysql_server_ip = aws_db_instance.mysql_rds.address })

  tags = {
    Name = "BackendServer"
  }
}

resource "aws_db_instance" "mysql_rds" {
  allocated_storage = 20
  engine = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"
  db_name = "bookmark_tool"
  username = "webuser"
  password = "lolpassword"
  parameter_group_name = "default.mysql8.0"
  publicly_accessible = true
  skip_final_snapshot = true

  vpc_security_group_ids = [ aws_security_group.allow_mysql.id ]

  tags = {
    Name = "MySQL-RDS"
  }
}

output "frontend_server_ip" {
  value = aws_instance.frontend_server.public_ip
}

output "backend_server_ip" {
  value = aws_instance.backend_server.public_ip
}

output "mysql_rds_endpoint" {
  value = aws_db_instance.mysql_rds.address
}