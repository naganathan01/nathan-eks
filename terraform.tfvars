# primary region
region = "us-east-1"


# cluster Variables values
cluster_name = "nathan-demo-cluster"
cluster_version = "1.29"   # need to be change
cluster_sg_group_name = "demo-cluster-sg"
cluster_iam_role_name = "demo-cluster-iam-role"
cluster_iam_policy_name = "demo-cluster-iam-policy"
cluster_endpoint_private_access = false
cluster_endpoint_public_access = true

# iam variables values
ingress_controller_iam_role_name = "demoingress-controller-iam-role"
ingress_controller_iam_policy_name = "demoingress-controller-iam-policy"
r53_policy_name = "demor53-policy"
r53_role_name = "demor53-role"
node_iam_role_name = "demonode-iam-role"

# linux node group variables values
linux_node_group_desired_capacity = 2
linux_node_group_max_capacity = 2
linux_node_group_min_capacity = 1
linux_node_group_name = "demo-linux-ng"
linux_sg_name = "demo-linux-sg"

#Vpc values
vpc_name = "nathan-test-vpc"
public_subnets =["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"]
private_subnets =["10.0.4.0/24","10.0.5.0/24","10.0.6.0/24"]
