provider "aws" {
    region  = "eu-west-1"
}

module "vpc" {
  source = "../../modules/vpc"
  name = "my-vpc"
  cidr = "10.0.0.0/16"
  azs             = ["eu-west-1a"]
  private_subnets = ["10.0.1.0/24"]
  public_subnets  = ["10.0.101.0/24"]
  enable_nat_gateway = true
  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

locals {
  cluster_name = "my-eks-cluster"
}

module "eks" {
  source       = "../../modules/eks"
  cluster_name = local.cluster_name
  vpc_id       = module.vpc.aws_vpc_id
  subnets      = aws_subnet.private.*.id

  node_groups = {
    eks_nodes = {
      desired_capacity = 3
      max_capacity     = 3
      min_capaicty     = 3

      instance_type = "t2.small"
    }
  }

  manage_aws_auth = false
}

