module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  cluster_endpoint_public_access = true

  # Add CloudWatch logging
  cluster_enabled_log_types = var.cluster_enabled_log_types

  eks_managed_node_groups = {
    general = {
      desired_size = var.node_group_desired_size
      min_size     = var.node_group_min_size
      max_size     = var.node_group_max_size

      instance_types = var.node_group_instance_types
      capacity_type  = var.node_group_capacity_type

      labels = {
        Environment = var.environment
        GithubRepo  = "materialize"
      }
    }
  }

  tags = var.tags
}

resource "aws_kms_key" "eks" {
  count = var.enable_cluster_encryption ? 1 : 0

  description             = "EKS Cluster ${var.cluster_name} Encryption Config KMS Key"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = var.tags
}

resource "aws_kms_alias" "eks" {
  count = var.enable_cluster_encryption ? 1 : 0

  name          = "alias/eks-${var.cluster_name}"
  target_key_id = aws_kms_key.eks[0].key_id
}