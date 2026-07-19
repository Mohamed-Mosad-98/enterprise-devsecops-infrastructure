module "eks" {

  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id = var.vpc_id

  subnet_ids = var.private_subnets

  enable_irsa = true

  cluster_endpoint_public_access = true

  create_iam_role = false

  iam_role_arn = var.cluster_role_arn

  eks_managed_node_groups = {

    default = {

      create_iam_role = false

      iam_role_arn = var.node_role_arn

      instance_types = ["m7i-flex.large"]

      capacity_type = "ON_DEMAND"

      min_size = 2

      desired_size = 2

      max_size = 3

      subnet_ids = var.private_subnets
    }
  }

  tags = var.tags
}
resource "aws_eks_access_entry" "terraform_admin" {
  cluster_name  = module.eks.cluster_name
  principal_arn = "arn:aws:iam::274585058347:user/terraform-admin"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "terraform_admin" {
  cluster_name  = module.eks.cluster_name
  principal_arn = "arn:aws:iam::274585058347:user/terraform-admin"
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}