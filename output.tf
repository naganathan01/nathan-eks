output "vpc_id" {
  value = aws_vpc.main.id
}

output "region" {
  value = var.region
}

output "cluster_name" {
  value = aws_eks_cluster.eks.name
}


output "ingress_name" {
  value = aws_iam_role.eks_alb_ingress_controller.arn
}
