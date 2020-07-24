provider "aws" {
  region     = "eu-central-1"
}
data "aws_region" "current" {
}
data "aws_caller_identity" "current" {}

data "aws_ami" "ubuntu" {
 most_recent = true
 owners = ["099720109477"]
 filter {
   name   = "name"
   values = ["ubuntu/*ubuntu-focal-20.04*amd64*server*"]
 }
 filter {
   name   = "root-device-type"
   values = ["ebs"]
 }

}

