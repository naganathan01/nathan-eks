/**************
# OIDC Provider
**************/
resource "aws_iam_openid_connect_provider" "default" {
  url = aws_eks_cluster.eks.identity[0].oidc[0].issuer
  client_id_list = [
    "sts.amazonaws.com",
  ]
  thumbprint_list = [var.eks_oidc_root_ca_thumbprint]
}

locals {
  OIDC_ARN     = aws_iam_openid_connect_provider.default.arn
  RAW_OIDC_URL = aws_eks_cluster.eks.identity[0].oidc[0].issuer
  OIDC_URL     = element(split("//", local.RAW_OIDC_URL), 1)
}



# Another policy to be attached to the node iam role is hte ingress controller policy.
# Search for "ingress-controller node iam role policy attachment" in this document below to find the policy attachment resource

/********************************
# IAM role for Ingress controller
********************************/
# This role arn should be exported to the outputs and replaced in ingress-controller.yml file before kubectl apply

resource "aws_iam_role" "eks_alb_ingress_controller" {
  name =  var.ingress_controller_iam_role_name
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "${local.OIDC_ARN}"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "${local.OIDC_URL}:aud": "sts.amazonaws.com",
            "${local.OIDC_URL}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
}
EOF

  depends_on = [aws_iam_openid_connect_provider.default]
}

/*****************************
# Ingress IAM policy Document
*****************************/
data "aws_iam_policy_document" "eks_alb_ingress" {
  statement {
    actions = [
      "acm:DescribeCertificate",
      "acm:ListCertificates",
      "acm:GetCertificate",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:CreateSecurityGroup",
      "ec2:CreateTags",
      "ec2:DeleteTags",
      "ec2:DeleteSecurityGroup",
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAddresses",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceStatus",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeTags",
      "ec2:DescribeVpcs",
      "ec2:ModifyInstanceAttribute",
      "ec2:ModifyNetworkInterfaceAttribute",
      "ec2:RevokeSecurityGroupIngress",
      "elasticloadbalancing:AddListenerCertificates",
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:CreateRule",
      "elasticloadbalancing:CreateTargetGroup",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:DeleteRule",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:DescribeListenerCertificates",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:DescribeSSLPolicies",
      "elasticloadbalancing:DescribeTags",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetGroupAttributes",
      "elasticloadbalancing:DescribeTargetHealth",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:ModifyRule",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:ModifyTargetGroupAttributes",
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:RemoveListenerCertificates",
      "elasticloadbalancing:RemoveTags",
      "elasticloadbalancing:SetIpAddressType",
      "elasticloadbalancing:SetSecurityGroups",
      "elasticloadbalancing:SetSubnets",
      "elasticloadbalancing:SetWebACL",
      "iam:CreateServiceLinkedRole",
      "iam:GetServerCertificate",
      "iam:ListServerCertificates",
      "waf-regional:GetWebACLForResource",
      "waf-regional:GetWebACL",
      "waf-regional:AssociateWebACL",
      "waf-regional:DisassociateWebACL",
      "tag:GetResources",
      "tag:TagResources",
      "waf:GetWebACL",
      "wafv2:GetWebACL",
      "wafv2:GetWebACLForResource",
      "wafv2:AssociateWebACL",
      "wafv2:DisassociateWebACL",
      "shield:DescribeProtection",
      "shield:GetSubscriptionState",
      "shield:DeleteProtection",
      "shield:CreateProtection",
      "shield:DescribeSubscription",
      "shield:ListProtections",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeVpcPeeringConnections",
      "ec2:GetCoipPoolUsage",
      "ec2:DescribeCoipPools"
    ]
    resources = ["*"]

  }
  statement {
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "ec2:DescribeLaunchTemplateVersions"
    ]
    resources = ["*"]

  }
  statement {
    actions = [
      "route53:ChangeResourceRecordSets",
      "cognito-idp:DescribeUserPoolClient"
    ]
    resources = ["arn:aws:route53:::hostedzone/*"]
  }
  statement {
    actions = [
      "route53:GetChange"
    ]
    resources = ["arn:aws:route53:::change/*"]

  }
  statement {
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
      "route53:ListHostedZonesByName",
      "route53:ListTagsForResource"
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "fsx:*"
    ]
    resources = ["*"]

  }
  statement {
    actions = [
      "iam:CreateServiceLinkedRole",
      "iam:AttachRolePolicy",
      "iam:PutRolePolicy"
    ]
    resources = ["arn:aws:iam::*:role/aws-service-role/*"]

  }
}

/*******************
# Ingress IAM Policy
*******************/

resource "aws_iam_policy" "eks_alb_ingress_policy" {
  name   = var.ingress_controller_iam_policy_name
  path   = "/"
  policy = data.aws_iam_policy_document.eks_alb_ingress.json
}

# Ingress controller policy to be attached to ingress controller iam role and node iam role
# ingress-controller node iam role policy attachment

resource "aws_iam_role_policy_attachment" "alb_ingress_policy" {
  for_each = toset([
    aws_iam_role.eks_alb_ingress_controller.name,
    aws_iam_role.eks_role_r53.name
  ])
#name       = "EKS-IAM-EC2PA-IngressControllerPolicy"
role     = each.value
policy_arn = aws_iam_policy.eks_alb_ingress_policy.arn
}

/***********************************************
 IAM Role Policy to create R53 from Externla DNS
***********************************************/

resource "aws_iam_policy" "eks_r53_policy" {
  name = var.r53_policy_name

  policy = jsonencode({
     Version: "2012-10-17",
     Statement = [
      {
        Effect = "Allow"
        Action = [
          "sts:AssumeRole",
        ]
        "Resource": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/external-dns-role"
      },
     ]
  })
}

resource "aws_iam_role" "eks_role_r53" {
  name  =  var.r53_role_name
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "${local.OIDC_ARN}"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "${local.OIDC_URL}:aud": "sts.amazonaws.com",
            "${local.OIDC_URL}:sub": "system:serviceaccount:default:r53svc"
          }
        }
      }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "r53_policy" {
  role    = aws_iam_role.eks_role_r53.name
  policy_arn = aws_iam_policy.eks_r53_policy.arn
}
