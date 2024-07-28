/************
# EKS Cluster
************/

resource "aws_eks_cluster" "eks" {
  name                      = var.cluster_name
  role_arn                  = aws_iam_role.cluster.arn
  version                   = var.cluster_version

  vpc_config {
    security_group_ids = [aws_security_group.cluster.id]
    subnet_ids = [aws_subnet.public_subnet[0].id,aws_subnet.public_subnet[1].id,aws_subnet.public_subnet[2].id]
    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = var.cluster_endpoint_public_access
    public_access_cidrs     = var.cluster_endpoint_public_access_cidrs
  }

  timeouts {
    create = var.cluster_create_timeout
    delete = var.cluster_delete_timeout
  }

  depends_on = [
    aws_iam_role_policy_attachment.Cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.Cluster_AmazonEKSServicePolicy,
    aws_security_group_rule.cluster_egress_internet
  ]
}

/***********************************
# Cluster - Security Group and rules
***********************************/

resource "aws_security_group" "cluster" {
  name = var.cluster_sg_group_name
  description = "EKS cluster security group"
  vpc_id      = aws_vpc.main.id
}


// SG Rule for the SG that is getting created by the cluster
resource "aws_security_group_rule" "cluster_private_access" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id
}

resource "aws_security_group_rule" "cluster_egress_internet" {
  description       = "Allow cluster egress access to the Internet."
  protocol          = "-1"
  security_group_id = aws_security_group.cluster.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

// Create ingress security group rule for RDP access to instance hosts

resource "aws_security_group_rule" "cluster_worker_ingress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.cluster.id
}




/**********************************************
# Cluster - Roles and there attachment policies
**********************************************/

resource "aws_iam_role" "cluster" {
  name                  = var.cluster_iam_role_name
  assume_role_policy    = data.aws_iam_policy_document.cluster_assume_role_policy.json
  path                  = "/"

}

resource "aws_iam_role_policy_attachment" "Cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "Cluster_AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "Cluster_AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "Cluster_PolicyNLB" {
  policy_arn = aws_iam_policy.cluster_eks_alb_ingress_policy.arn
  role       = aws_iam_role.cluster.name
}

data "aws_iam_policy_document" "eks_cluster_alb_ingress" {
  statement {
    actions = [
      "elasticloadbalancing:*",
      "ec2:CreateSecurityGroup",
      "ec2:Describe*",
      "cloudwatch:PutMetricData"
    ]
    resources = ["*"]

  }
}
resource "aws_iam_policy" "cluster_eks_alb_ingress_policy" {
  name   = var.cluster_iam_policy_name
  path   = "/"
  policy = data.aws_iam_policy_document.eks_cluster_alb_ingress.json
}
