resource "aws_eks_cluster" "kube-practice" {
  name     = var.cluster_name
  role_arn = aws_iam_role.kube-practice.arn
  version  = var.kube_version
  vpc_config {
    # subnet_ids = [aws_subnet.public[*].id]
    subnet_ids = aws_subnet.public[*].id
    endpoint_public_access = true
    # public_access_cidrs = [local.my_ip_addrs]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.kube-practice-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.kube-practice-AmazonEKSVPCResourceController,
  ]
}

resource "aws_iam_role" "kube-practice" {
  name = "eks-cluster-kube-practice"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "kube-practice-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.kube-practice.name
}
# # Optionally, enable Security Groups for Pods
# # Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "kube-practice-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.kube-practice.name
}


data "tls_certificate" "kube-practice-ser-account" {
  url = aws_eks_cluster.kube-practice.identity[0].oidc[0].issuer
  # url = aws_eks_cluster.kube-practice.identity[0].oidc[0].issuer ? null : null
}


resource "aws_iam_openid_connect_provider" "kube-practice-ser-account" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.kube-practice-ser-account.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.kube-practice.identity[0].oidc[0].issuer
}

data "aws_iam_policy_document" "kube-practice-ser-account_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.kube-practice-ser-account.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.kube-practice-ser-account.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "kube-practice-ser-account" {
  assume_role_policy = data.aws_iam_policy_document.kube-practice-ser-account_assume_role_policy.json
  name               = "kube-practice-ser-account"
}


# resource "aws_eks_cluster" "kube-practice" {
#   name     = "kubernetes-practice"
#   role_arn = aws_iam_role.kube-practice.arn
#   version  = var.kube_version
#   vpc_config {
#     subnet_ids = aws_subnet.public[*].id
#     endpoint_public_access = true
#     public_access_cidrs = [local.my_ip_addrs]
#   }

#   # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
#   # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
#   depends_on = [
#     aws_iam_role_policy_attachment.kube-practice-AmazonEKSClusterPolicy,
#     aws_iam_role_policy_attachment.kube-practice-AmazonEKSVPCResourceController,
#   ]
# }

# resource "aws_iam_role" "kube-practice" {
#   name = "eks-cluster-kube-practice"

#   assume_role_policy = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "eks.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# POLICY
# }

# resource "aws_iam_role_policy_attachment" "kube-practice-AmazonEKSClusterPolicy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
#   role       = aws_iam_role.kube-practice.name
# }
# # # Optionally, enable Security Groups for Pods
# # # Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
# resource "aws_iam_role_policy_attachment" "kube-practice-AmazonEKSVPCResourceController" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
#   role       = aws_iam_role.kube-practice.name
# }


# data "tls_certificate" "kube-practice-ser-account" {
#   url = aws_eks_cluster.kube-practice.identity[0].oidc[0].issuer
#   # url = aws_eks_cluster.kube-practice.identity[0].oidc[0].issuer ? null : null
# }


# resource "aws_iam_openid_connect_provider" "kube-practice-ser-account" {
#   client_id_list  = ["sts.amazonaws.com"]
#   thumbprint_list = [data.tls_certificate.kube-practice-ser-account.certificates[0].sha1_fingerprint]
#   url             = aws_eks_cluster.kube-practice.identity[0].oidc[0].issuer
# }

# data "aws_iam_policy_document" "kube-practice-ser-account_assume_role_policy" {
#   statement {
#     actions = ["sts:AssumeRoleWithWebIdentity"]
#     effect  = "Allow"

#     condition {
#       test     = "StringEquals"
#       variable = "${replace(aws_iam_openid_connect_provider.kube-practice-ser-account.url, "https://", "")}:sub"
#       values   = ["system:serviceaccount:kube-system:aws-node"]
#     }

#     principals {
#       identifiers = [aws_iam_openid_connect_provider.kube-practice-ser-account.arn]
#       type        = "Federated"
#     }
#   }
# }

# resource "aws_iam_role" "kube-practice-ser-account" {
#   assume_role_policy = data.aws_iam_policy_document.kube-practice-ser-account_assume_role_policy.json
#   name               = "kube-practice-ser-account"
# }

