
/***************************************
# Cluster - NodeGroups(Controller Nodes)
***************************************/

resource "aws_eks_node_group" "linux_node_group" {

  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = var.linux_node_group_name
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = [aws_subnet.private_subnet[0].id,aws_subnet.private_subnet[1].id,aws_subnet.private_subnet[2].id]

  ami_type = "AL2_x86_64"
  instance_types = ["t3.medium"]

  scaling_config {
    desired_size = var.linux_node_group_desired_capacity
    max_size     = var.linux_node_group_max_capacity
    min_size     = var.linux_node_group_min_capacity
  }

}


/************************************
# Linux Nodes IAM Role & policy Attachments
************************************/
resource "aws_iam_role" "node" {
  name =  var.node_iam_role_name
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": ["ec2.amazonaws.com", "ssm.amazonaws.com"]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# These are mandatory policies to be attached to the EKS nodes
variable "node_policies" {
  type    = list(string)
  default = [
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    ]
}

resource "aws_iam_role_policy_attachment" "eks_node_policies" {
  count      = length(var.node_policies)
  role       = aws_iam_role.node.name
  policy_arn = var.node_policies[count.index]
}



/**********************************************************
# Nodes Security Groups & Rules for Linux
**********************************************************/

resource "aws_security_group" "workers" {
  name= var.linux_sg_name
  description = "Security group for all nodes in the cluster."
  vpc_id      = aws_vpc.main.id
}

resource "aws_security_group_rule" "SSH_ingress_workers" {
  description       = "Allow user to SSH to the linux worker nodes"
  protocol          = "tcp"
  security_group_id = aws_security_group.workers.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 22
  to_port           = 22
  type              = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster_https" {
  description              = "Allow pods running extension API servers on port 443 to receive communication from cluster control plane."
  protocol                 = "tcp"
  security_group_id        = aws_security_group.workers.id
  source_security_group_id = aws_security_group.cluster.id
  from_port                = 443
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster_http" {
  description              = "Allow pods running extension API servers on port 443 to receive communication from cluster control plane."
  protocol                 = "tcp"
  security_group_id        = aws_security_group.workers.id
  source_security_group_id = aws_security_group.cluster.id
  from_port                = 80
  to_port                  = 80
  type                     = "ingress"
}
