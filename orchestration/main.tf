provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}


module "namespace" {
source = "../modules/namespace"
name = var.name
}

module "helm-efk" {
  source = "../modules/helm-release"
  for_each 	 = var.application-name
  application-name = "${each.value.application-name}"
  repository = "${each.value.repository}"
  chart = "${each.value.chart}"
  namespace = "${each.value.namespace}"
}
