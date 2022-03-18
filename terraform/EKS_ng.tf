resource "aws_eks_node_group" "kube-practice" {
  cluster_name    = aws_eks_cluster.kube-practice.name
  node_group_name = "kube-practice"
  node_role_arn   = aws_iam_role.eks_node_group.arn
  subnet_ids      = aws_subnet.public[*].id
  ami_type        = "AL2_x86_64"
  capacity_type   = "SPOT"
  disk_size       = "20"
  instance_types  = ["t3.large"]
  remote_access {
      ec2_ssh_key = var.ec2_key_name
      # source_security_group_ids = [aws_security_group.eks_node_group.id]
  }

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_iam_role" "eks_node_group" {
  name = "eks-node-group"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group.name
}


resource "aws_security_group" "eks_node_group" {
  ingress {
    description = "From My IP"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [local.my_ip_addrs]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = aws_vpc.vpc_main.id
  name = format(
      "%s-%s-eks_node_group-sg",
      var.company,
      var.environment
    )
  description = format(
      "%s-%s-eks_node_group-sg",
      var.company,
      var.environment
    )
  tags = {
    Name = format(
      "%s-%s-eks_node_group-sg",
      var.company,
      var.environment
    )
  }
}


# resource "aws_eks_node_group" "kube-practice" {
#   cluster_name    = aws_eks_cluster.kube-practice.name
#   node_group_name = "kube-practice-111"
#   node_role_arn   = aws_iam_role.eks_node_group.arn
#   subnet_ids      = aws_subnet.public[*].id
#   ami_type        = "AL2_x86_64"
#   capacity_type   = "SPOT"
#   disk_size       = "20"
#   instance_types  = ["t3.medium"]
#   remote_access {
#       ec2_ssh_key = var.ec2_key_name
#       source_security_group_ids = [aws_security_group.eks_node_group.id]
#   }

#   scaling_config {
#     desired_size = 1
#     max_size     = 1
#     min_size     = 1
#   }

#   # tags = {
#   #   Name = format(
#   #     "%s-%s-eks_node_group-sg",
#   #     var.company,
#   #     var.environment
#   #   )
#   # }

#   # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
#   # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
#   depends_on = [
#     aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
#     aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
#     aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
#   ]
# }

# resource "aws_iam_role" "eks_node_group" {
#   name = "eks-node-group"

#   assume_role_policy = jsonencode({
#     Statement = [{
#       Action = "sts:AssumeRole"
#       Effect = "Allow"
#       Principal = {
#         Service = "ec2.amazonaws.com"
#       }
#     }]
#     Version = "2012-10-17"
#   })
# }

# resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
#   role       = aws_iam_role.eks_node_group.name
# }

# resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
#   role       = aws_iam_role.eks_node_group.name
# }

# resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
#   role       = aws_iam_role.eks_node_group.name
# }


# resource "aws_security_group" "eks_node_group" {
#   ingress {
#     description = "From My IP"
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = [local.my_ip_addrs]
#   }
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   vpc_id = aws_vpc.vpc_main.id
#   name = format(
#       "%s-%s-eks_node_group-sg",
#       var.company,
#       var.environment
#     )
#   description = format(
#       "%s-%s-eks_node_group-sg",
#       var.company,
#       var.environment
#     )
#   tags = {
#     Name = format(
#       "%s-%s-eks_node_group-sg",
#       var.company,
#       var.environment
#     )
#   }
# }
