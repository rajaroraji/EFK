
resource "helm_release" "fluent" {
  name       = "fluent"
  repository = "https://fluent.github.io/helm-charts"
  chart      = "fluent-bit"
  version    = "0.19.20"
  namespace  = "efk"
  verify     = false
}
