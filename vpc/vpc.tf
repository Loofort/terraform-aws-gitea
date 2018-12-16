# VPC 
resource "aws_vpc" "this" {
  tags                 = "${var.tags}"
  cidr_block           = "${var.cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.this.id}"
  tags   = "${var.tags}"
}

# Publiс router
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.this.id}"
  tags   = "${var.tags}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
}

# Subnet
resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.this.id}"
  tags                    = "${var.tags}"
  cidr_block              = "${var.cidr_subnet}"
  availability_zone       = "${local.az}"
  map_public_ip_on_launch = true
}
resource "aws_route_table_association" "public" {
  subnet_id      = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public.id}"
}
