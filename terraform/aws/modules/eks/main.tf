locals {
  environment_name = "${var.building_block}-${var.environment}"
  cluster_name     = "${local.environment_name}-cluster"
  
  common_tags = {
    Environment    = var.environment
    BuildingBlock  = var.building_block
    ManagedBy      = "Terraform"
    CloudProvider  = "AWS"
  }
}

# EKS Module using terraform-aws-modules/eks
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"
  
  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version
  
  vpc_id                    = var.vpc_id
  subnet_ids                = var.private_subnet_ids
  control_plane_subnet_ids  = var.private_subnet_ids
  
  # Cluster endpoint access
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true
  
  # Enable IRSA (IAM Roles for Service Accounts)
  enable_irsa = true
  
  # Cluster addons
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_driver_irsa.iam_role_arn
    }
  }
  
  # EKS Managed Node Group
  eks_managed_node_groups = {
    default = {
      name            = "${local.cluster_name}-node-group"
      use_name_prefix = true
      
      min_size     = var.node_count_min
      max_size     = var.node_count_max
      desired_size = var.node_count_min
      
      instance_types = [var.node_instance_type]
      capacity_type  = "ON_DEMAND"
      
      disk_size = var.node_disk_size_gb
      
      labels = {
        Environment   = var.environment
        BuildingBlock = var.building_block
      }
      
      tags = merge(
        local.common_tags,
        {
          Name = "${local.cluster_name}-node-group"
        }
      )
    }
  }
  
  # Cluster security group
  cluster_security_group_additional_rules = {
    ingress_nodes_ephemeral_ports_tcp = {
      description                = "Nodes on ephemeral ports"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "ingress"
      source_node_security_group = true
    }
  }
  
  # Node security group
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    
    ingress_cluster_all = {
      description                   = "Cluster to node all ports/protocols"
      protocol                      = "-1"
      from_port                     = 0
      to_port                       = 0
      type                          = "ingress"
      source_cluster_security_group = true
    }
    
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }
  
  tags = local.common_tags
}

# IAM role for EBS CSI Driver
module "ebs_csi_driver_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"
  
  role_name_prefix = "${local.cluster_name}-ebs-csi-"
  
  attach_ebs_csi_policy = true
  
  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
  
  tags = local.common_tags
}

# Update kubeconfig
resource "null_resource" "update_kubeconfig" {
  triggers = {
    cluster_endpoint = module.eks.cluster_endpoint
  }
  
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
  }
  
  depends_on = [module.eks]
}

# Create internal load balancer for private ingress
resource "kubernetes_service" "private_lb_placeholder" {
  metadata {
    name      = "private-lb-placeholder"
    namespace = "default"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type"                              = "nlb"
      "service.beta.kubernetes.io/aws-load-balancer-internal"                          = "true"
      "service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled" = "true"
    }
  }
  
  spec {
    type = "LoadBalancer"
    
    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }
    
    selector = {
      app = "private-lb-placeholder"
    }
  }
  
  depends_on = [module.eks]
}
