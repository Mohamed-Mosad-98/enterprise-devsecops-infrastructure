module "vpc" {
  source = "./modules/vpc"

  name = "${local.name_prefix}-vpc"

  cidr = var.vpc_cidr

  azs = var.availability_zones

  public_subnets = var.public_subnets

  private_subnets = var.private_subnets

  tags = local.common_tags
}
module "iam" {
  source = "./modules/iam"

  cluster_name = "${local.name_prefix}-eks"

  tags = local.common_tags
}
module "ecr" {
  source = "./modules/ecr"

  repository_name = "${local.name_prefix}-application"

  tags = local.common_tags
}
module "eks" {

  source = "./modules/eks"

  cluster_name = "${local.name_prefix}-eks"

  cluster_version = "1.33"

  vpc_id = module.vpc.vpc_id

  private_subnets = module.vpc.private_subnets

  cluster_role_arn = module.iam.cluster_role_arn

  node_role_arn = module.iam.node_role_arn

  tags = local.common_tags
}