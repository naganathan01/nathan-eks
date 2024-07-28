
# Region Variables
variable "region" {
  type = string
  default = null
}


/**********************************************
# Cluster Variables
**********************************************/

variable "cluster_name" {
  type = string
  default = null
}

variable "cluster_version" {
  default = null
}

variable "cluster_sg_group_name" {
  default = null
}

variable "cluster_iam_role_name" {
  default = null
}

variable "cluster_iam_policy_name" {
  default = null
}

variable "cluster_endpoint_private_access" {
  type        = bool
  default     = false
}

variable "cluster_endpoint_public_access" {
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cluster_create_timeout" {
  description = "Timeout value when creating the EKS cluster."
  type        = string
  default     = "30m"
}

variable "cluster_delete_timeout" {
  description = "Timeout value when deleting the EKS cluster."
  type        = string
  default     = "15m"
}

variable "eks_oidc_root_ca_thumbprint" {
  type        = string
  description = "Thumbprint of Root CA for EKS OIDC, Valid until 2037"
  default     = "9e99a48a9960b14926bb7f3b02e22da2b0ab7280"
}

/**********************************************
#  iam Variables
**********************************************/

variable "ingress_controller_iam_role_name" {
  default = null
}

variable "ingress_controller_iam_policy_name" {
  default = null
}

variable "r53_policy_name" {
  default = null
}

variable "r53_role_name" {
  default = null
}



/**********************************************
#  Linux node group Variables
**********************************************/
variable "linux_node_group_desired_capacity" {
  default = null
}

variable "linux_node_group_min_capacity" {
  default = null
}

variable "linux_node_group_max_capacity" {
  default = null
}

variable "linux_node_group_name" {
  default = null
}

variable "node_iam_role_name" {
  default = null
}

variable "linux_sg_name" {
  default = null
}

/**********************************************
#  Vpc Variables
**********************************************/
variable "vpc_name" {
  default = null
}

variable "public_subnets" {
  default = null
}

variable "private_subnets" {
  default = null
}
