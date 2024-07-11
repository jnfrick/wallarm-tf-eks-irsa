variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-1"
}

variable "eks_cluster_name" {
  description = "Cluster name prefix - random suffix will be created"
  type        = string
  default     = "jfrick-eks"
}

variable "irsa_name" {
  description = "Name of the IRSA to be used for Wallarm serviceRole"
  type        = string
  default     = "wallarm-irsa-test"
}

variable "wallarm_namespace" {
  description = "Name of the namespace to install Wallarm Ingress into"
  type        = string
  default     = "wallarm"
}

variable "wallarm_service_account" {
  description = "Name of the service account to create in K8s for use with Wallarm"
  type        = string
  default     = "wallarm-svc-acct"
}

variable "wallarm_token" {
  description = "API token created in Wallarm Console > Settings > API Tokens with Deploy permissions"
  type        = string
  default     = "<WALLARM_API_TOKEN>"
}

variable "wallarm_api_host" {
  description = "Set which cloud your tenant is in:  US = us1.api.wallarm.com   EU = api.wallarm.com"
  type        = string
  default     = "us1.api.wallarm.com"
}

variable "wallarm_node_group" {
  description = "Create or use existing group folder to display the new Wallarm nodes in on the Wallarm Console"
  type        = string
  default     = "EKS-Nodes"
}

# UNCOMMENT IF YOU HAVE NEED TO INSTALL A SPECIFIC VERSION OF WALLARM.  OTHERWISE LATEST VERSION WILL BE INSTALLED
#variable "wallarm_version" {
#  description = "Version of Wallarm node to install onto the EKS cluster"
#  type        = string
#  default     = "4.10.7"
#}

