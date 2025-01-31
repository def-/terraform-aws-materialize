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
    "${var.environment}-mz-workers" = {
      desired_size = var.node_group_desired_size
      min_size     = var.node_group_min_size
      max_size     = var.node_group_max_size

      instance_types = var.node_group_instance_types
      capacity_type  = var.node_group_capacity_type
      ami_type       = var.node_group_ami_type

      name = "${var.environment}-mz"

      labels = {
        Environment              = var.environment
        GithubRepo               = "materialize"
        "materialize.cloud/disk" = "true"
        "workload"               = "materialize-instance"
      }
    }
  }

  # Cluster access entry
  # To add the current caller identity as an administrat
  enable_cluster_creator_admin_permissions = var.enable_cluster_creator_admin_permissions

  tags = var.tags
}
