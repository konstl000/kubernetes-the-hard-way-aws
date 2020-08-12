module "vpc" {
  source = "../shared/modules/vpc"
  nat-subnet      = 0
  use-nat = false
  default_tags = var.default_tags
  private_subnet_tags = {
    "kubernetes.io/cluster/kubernetes-the-hard-way" = "owned"
  }
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }
  cidr_range = var.cidr_block
  private_subnet_cidrs = {
        0 = "10.200.1.0/24"
        1 = "10.200.2.0/24"
        2 = "10.200.3.0/24"
  }
  public_subnet_cidrs = {
        0 = "10.200.10.0/24"
        1 = "10.200.11.0/24"
        2 = "10.200.12.0/24"
  }
  private2public = true
  secondary_cidrs = ["10.32.0.0/16"]
}

