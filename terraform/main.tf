terraform {
  required_version = ">= 1.5.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
}

# Utilise le kubeconfig local (Minikube)
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}

# ── Namespace pour l'application ──────────────────────────────────────────────
resource "kubernetes_namespace" "devops_tp" {
  metadata {
    name = "devops-tp"
    labels = {
      project     = "devops-tp"
      environment = "local"
      managed-by  = "terraform"
    }
  }
}

# ── Namespace pour le monitoring ──────────────────────────────────────────────
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
    labels = {
      project    = "devops-tp"
      managed-by = "terraform"
    }
  }
}

# ── Outputs ───────────────────────────────────────────────────────────────────
output "app_namespace" {
  value       = kubernetes_namespace.devops_tp.metadata[0].name
  description = "Namespace de l'application"
}

output "monitoring_namespace" {
  value       = kubernetes_namespace.monitoring.metadata[0].name
  description = "Namespace du monitoring"
}
