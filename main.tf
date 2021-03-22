provider "aws" {
    region = "us-east-1"
    // not recommended to use static credentials
    access_key = "my-access-key"
    secret_key = "my-secret-key"
}