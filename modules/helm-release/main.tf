provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "my-applications" {

  name = var.application-name

  repository = var.repository
  chart      = var.chart
  namespace  = var.namespace
  create_namespace = var.create_namespace
  values = [
    file("${path.vars}/values.yaml")
  ]
}
