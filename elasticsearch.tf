provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}


resource "helm_release" "elasticsearch" {
  name       = "elasticsearch"
  repository = "https://helm.elastic.co/"
  chart      = "elasticsearch"
  version    = "7.17.3"
  namespace  = "efk"
  create_namespace = true
  verify     = false
  values = [
    "${file("esvalue.yaml")}"
  ]
}
