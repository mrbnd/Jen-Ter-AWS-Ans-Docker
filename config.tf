provider "aws" {
  access_key = "access_key"
  secret_key = "secret_key"
  region = "us-east-2"
}

resource "tls_private_key" "privkey" {
    algorithm = "RSA"
    rsa_bits = 4096
}

output "tls_private_key" { value = "${tls_private_key.privkey.private_key_pem}" }

resource "aws_security_group" "security_group" {
  name        = "lab_security_group"
  description = "Security group configuration for lab"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
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

resource "aws_key_pair" "public_key" {
  key_name   = "lab_key"
  public_key = "${tls_private_key.privkey.public_key_openssh}"
}

resource "aws_instance" "build" {
  instance_type = "t2.micro"
  ami           = "ami-0a63f96e85105c6d3"
  security_groups = ["${aws_security_group.security_group.name}"]
  key_name = "${aws_key_pair.public_key.key_name}"

  connection {
    host        = "${aws_instance.build.public_dns}"
    type        = "ssh"
    agent       = false
    private_key = "${tls_private_key.privkey.private_key_pem}"
    user        = "ubuntu"
  }

  provisioner "file" {
    source      = "/tmp/jenkins/files/"
    destination = "/tmp/"
  }

  provisioner "remote-exec" {
    inline = [
      "cd /tmp/",
      "sudo apt-get -y update",
      "sudo apt-add-repository -y ppa:ansible/ansible",
      "sudo apt-add-repository --yes --update ppa:ansible/ansible",
      "sudo apt-get -y install ansible",
      "sudo ansible-playbook playbook.yml"

    ]
  }

 }

resource "aws_instance" "deploy" {
  instance_type = "t2.micro"
  ami           = "ami-0a63f96e85105c6d3"
  security_groups = ["${aws_security_group.security_group.name}"]
  key_name = "${aws_key_pair.public_key.key_name}"

  connection {
    host        = "${aws_instance.deploy.public_dns}"
    type        = "ssh"
    agent       = false
    private_key = "${tls_private_key.privkey.private_key_pem}"
    user        = "ubuntu"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "sudo apt-get -y install docker.io",
      "sudo docker run -it -d -p 8080:8080 username/repo:deploy"
    ]
  }

}


