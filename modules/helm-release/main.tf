resource "helm_release" "my-applications" {

  name = var.application-name

  repository = var.repository
  chart      = var.chart
  namespace  = var.namespace
  values = [
    file("${path.vars}/esvalues.yaml")
  ]
}
