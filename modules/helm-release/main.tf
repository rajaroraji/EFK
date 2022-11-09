resource "helm_release" "my-applications" {

  name = var.application-name

  repository = var.repository
  chart      = var.chart
  namespace  = var.namespace
  verify     = false
}
