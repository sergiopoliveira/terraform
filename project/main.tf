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
# 5. Associate subnet with Route Table
# 6. Create Security Group to allow port 22, 80, 443
# 7. Create a network interface with an ip in the subnet that was created in step 4
# 8. Assign an elastic IP (public IP address) to the network interface created in step 7
# 9. Create Ubuntu server and install/enable apache2