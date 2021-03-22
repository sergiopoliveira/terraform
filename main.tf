provider "aws" {
    region = "us-east-1"
    # not recommended to use static credentials
    access_key = "my-access-key"
    secret_key = "my-secret-key"
}

resource "aws_instance" "my-first-server" {
    ami = "ami-085925f297f89fce1"
    instance_type = "t2.micro"

    tags = {
        Name = "ubuntu"
    } 
}

resource "aws_vpc" "first-vpc" {
    cidr_block = "10.0.0.0/16"

    tags = {
        Name = "production-vpc"
    }
}

#resource "<provider>_<resource_type>" "name" {
#    config options...
#    key = "value"
#    key2 = "another value"
#}