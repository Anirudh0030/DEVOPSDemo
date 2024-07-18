provider "aws" {
    region = "us-east-1"
  #"argument" = "this is argument value"    
}

resource "aws_instance" "demo-server" {
    ami = "ami-04a81a99f5ec58529"
    instance_type = "t2.micro"
    key_name = "NewKEYPAIR"
    //security_groups = [ "demo-sg" ]
    vpc_security_group_ids = [ aws_security_group.demo-sg.id ]
    subnet_id = aws_subnet.demo-public-subnet-01.id
for_each = toset(["jenkins-master", "build-slave", "ansible"])
   tags = {
     Name = "${each.key}"
   }
}
resource "aws_security_group" "demo-sg" {
  name        = "demo-sg"
  description = "SSH Access"
  vpc_id = aws_vpc.demo-vpc.id
  
  ingress {
    description      = "Shh access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    }


    ingress {
    description      = "Jenkins port"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "ssh-prot"

  }
}
#creating VPC
resource "aws_vpc" "demo-vpc" {
    cidr_block = "10.1.0.0/16"
    tags = {
        Name = "demo-vpc"
    }  
}
#creating subnet-01
resource "aws_subnet" "demo-public-subnet-01"{
    vpc_id = aws_vpc.demo-vpc.id
    cidr_block = "10.1.1.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "us-east-1a"
    tags = {
        Name = "demo-public-subnet-01"
    }
}
#creating subnet-02
resource "aws_subnet" "demo-public-subnet-02"{
    vpc_id = aws_vpc.demo-vpc.id
    cidr_block = "10.1.2.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "us-east-1b"
    tags = {
        Name = "demo-public-subnet-02"
    }
}

#creating internet gateway
resource "aws_internet_gateway" "demo-igw" {
    vpc_id = aws_vpc.demo-vpc.id
    tags = {
        Name = "demo-igw"
    }
}

#creating route table

resource "aws_route_table" "demo-public-rt" {
    vpc_id = aws_vpc.demo-vpc.id
    route  {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.demo-igw.id
    }
}

#Creating route table association

resource "aws_route_table_association" "demo-rta-public-subnet-01" {
    subnet_id = aws_subnet.demo-public-subnet-01.id
    route_table_id = aws_route_table.demo-public-rt.id
  
}
#Creating route table association for subnet 2

resource "aws_route_table_association" "demo-rta-public-subnet-02" {
    subnet_id = aws_subnet.demo-public-subnet-02.id
    route_table_id = aws_route_table.demo-public-rt.id
  
}