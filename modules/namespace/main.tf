resource "kubernetes_namespace" "efk" {
  metadata {
    name = "efk"
  }
}