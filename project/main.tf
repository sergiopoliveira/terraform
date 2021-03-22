provider "aws" {
    region = "us-east-1"
    # not recommended to use static credentials
    access_key = "my-access-key"
    secret_key = "my-secret-key"
}

# 1. Create vpc
resource "aws_vpc" "prod-vpc" {
    cidr_block = "10.0.0.0/16"
    
    tags {
        Name = "production"
    }
}

# 2. Create Internet Gateway
resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.prod-vpc.id
}

# 3. Create Custom Route Table
resource "aws_route_table" "prod-route-table" {
    vpc_id = aws_vpc.prod-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gw.id
    }

    route {
        ipv6_cidr_block = "::/0"
        egress_only_gateway_id = aws_internet_gateway.gw.id
    }

    tags {
        Name = "Prod"
    }
}

# 4. Create a Subnet
resource "aws_subnet" "subnet-1" {
    vpc_id = aws_vpc.prod-vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"

    tags {
        Name = "prod-subnet"
    }
}

# 5. Associate subnet with Route Table
resource "aws_route_table_association" "a" {
    subnet_id = aws_subnet.subnet-1.id
    route_table_id = aws_route_table.prod-route-table.id
}

# 6. Create Security Group to allow port 22, 80, 443
resource "aws_security_group" "allow_web" {
    name = "allow_web_traffic"
    description = "Allow web inbound traffic"
    vpc_id = aws_vpc.prod-vpc.id

    ingress {
        description "HTPPS"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_block = ["0.0.0.0/0"]
    }

        ingress {
        description "HTTP"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_block = ["0.0.0.0/0"]
    }

        ingress {
        description "SSH"
        from_port = 2
        to_port = 2
        protocol = "tcp"
        cidr_block = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_block = ["0.0.0.0/0"]
    }

    tags = {
        Name = "allow_web"
    }
}

# 7. Create a network interface with an ip in the subnet that was created in step 4
resource "aws_network_interface" "web-server-nic" {
    subnet_id = aws_subnet.subnet-1.id
    private_ips = ["10.0.1.50"]
    security_groups = [aws_security_group.allow-web.id]
}

# 8. Assign an elastic IP (public IP address) to the network interface created in step 7
# 9. Create Ubuntu server and install/enable apache2