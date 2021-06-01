resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"

  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "my_vpc"
  }
}

resource "aws_subnet" "public"{
  vpc_id  = aws_vpc.my_vpc.id
  availability_zone = "us-east-1a"
  cidr_block = "10.0.10.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet"
  }
}

resource "aws_subnet" "public2"{
  vpc_id  = aws_vpc.my_vpc.id
  availability_zone = "us-east-1b"
  cidr_block = "10.0.15.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet2"
  }
}

resource "aws_subnet" "private_ws"{
  vpc_id = aws_vpc.my_vpc.id
  availability_zone = "us-east-1a"
  cidr_block = "10.0.20.0/24"

  tags = {
    Name = "private_subnet_webserver"
  }
}

resource "aws_subnet" "private_ws2"{
  vpc_id = aws_vpc.my_vpc.id
  availability_zone = "us-east-1b"
  cidr_block = "10.0.25.0/24"

  tags = {
    Name = "private_subnet_webserver2"
  }
}

resource "aws_subnet" "private_db"{
  vpc_id = aws_vpc.my_vpc.id
  availability_zone = "us-east-1a"
  cidr_block = "10.0.30.0/24"

  tags = {
    Name = "private_subnet_database"
  }
}

resource "aws_subnet" "private_db2"{
  vpc_id = aws_vpc.my_vpc.id
  availability_zone = "us-east-1b"
  cidr_block = "10.0.35.0/24"

  tags = {
    Name = "private_subnet_database2"
  }
}

resource "aws_internet_gateway" "igw"{
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_default_route_table" "public_rt"{
  default_route_table_id = aws_vpc.my_vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_gateway_rout_table"
  }
}

resource "aws_db_subnet_group" "rds_sg" {
  subnet_ids = [aws_subnet.private_db.id, aws_subnet.private_db2.id, aws_subnet.public.id]
}