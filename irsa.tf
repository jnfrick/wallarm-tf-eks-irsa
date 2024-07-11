provider "aws" {
  region = var.region
}

# Gain access to EKS cluster
provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks_cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority.0.data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.eks_cluster.name]
  }
}

# Get EKS cluster auth to read token
data "aws_eks_cluster_auth" "cluster" {
  name = var.eks_cluster_name
}

# Get EKS cluster details
data "aws_eks_cluster" "eks_cluster" {
  name = var.eks_cluster_name
}

# Get pre-created IRSA role
data "aws_iam_role" "irsa_role" {
  name = var.irsa_name
}

# Create new namespace for Wallarm ingress
resource "kubernetes_namespace" "wallarming" {
  metadata {
    name = var.wallarm_namespace
  }
}

# Create and annotate Kubernetes service account
resource "kubernetes_service_account" "wallarm_svc_acct" {
  metadata {
    name      = var.wallarm_service_account
    namespace = kubernetes_namespace.wallarming.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = data.aws_iam_role.irsa_role.arn
    }
  }
}

# Explicitly configure Helm provider to use Kubernetes provider context
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks_cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority.0.data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.eks_cluster.name]
    }
  }
}

# Deploy Wallarm using Helm chart
resource "helm_release" "wallarm" {
  name       = "wallarm"
  repository = "https://charts.wallarm.com"
  chart      = "wallarm-ingress"
  #version    = var.wallarm_version  # Uncomment this line to install a specific version of Wallarm defined in variables.tf
  namespace  = kubernetes_namespace.wallarming.metadata[0].name

  values = [
    <<EOF
controller:
  wallarm:
    enabled: true
    token: "${var.wallarm_token}"
    apiHost: "${var.wallarm_api_host}"
    nodeGroup: "${var.wallarm_node_group}"
serviceAccount:
  create: false
  name: ${var.wallarm_service_account}
EOF
  ]
}