output "clsuter_name" {
  value = aws_eks_cluster.kube-practice.name
}

output "endpoint" {
  value = aws_eks_cluster.kube-practice.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.kube-practice.certificate_authority[0].data
}
