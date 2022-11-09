
resource "helm_release" "kibana" {
  name       = "kibana"
  repository = "https://helm.elastic.co"
  chart      = "kibana"
  version    = "7.17.1"
  namespace  = "efk"
  verify     = false
  set {
    name  = "cluster.enabled"
    value = "NodePort"
  }
  set {
    name  = "service.nodePort"
    value = "31000"
  }
}

