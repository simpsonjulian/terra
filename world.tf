variable "name_tag" {
  default = "Terraform Example"
}

variable "ami_id" {
}

provider "aws" {
  region     = "ap-southeast-2"
}

resource "aws_vpc" "terra" {
  cidr_block = "10.0.0.0/16"
  tags {Name = "${var.name_tag}"}
}

resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.terra.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.terra.id}"
}

resource "aws_internet_gateway" "terra" {
  vpc_id = "${aws_vpc.terra.id}"
}

resource "aws_subnet" "terra" {
  vpc_id                  = "${aws_vpc.terra.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = false
}

resource "aws_instance" "terra" {
  ami           = "${var.ami_id}"
  instance_type = "t2.micro"
  subnet_id     = "${aws_subnet.terra.id}"
  security_groups = ["${aws_security_group.terra.id}"]
  tags {Name = "${var.name_tag}"}
}

resource "aws_security_group" "terra" {
  name        = "terraform_example_elb"
  vpc_id      = "${aws_vpc.terra.id}"

  ingress {
    from_port   = 80
    to_port     = 80
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

resource "aws_elb" "terra" {
  name = "hello-terra-elb"
  subnets         = ["${aws_subnet.terra.id}"]
  security_groups = ["${aws_security_group.terra.id}"]
  instances       = ["${aws_instance.terra.id}"]
  tags {Name = "${var.name_tag}"}

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}

output "url" {
  value = "http://${aws_elb.terra.dns_name}/"
}
