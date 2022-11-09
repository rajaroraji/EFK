provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}


module "namespace" {
name = var.namespace-name
}

module "helm-efk" {
  source = "../../modules/helm-release"
  for_each 	 = var.helm-application
  name= "${each.value.application-name}"
  repository = "${each.value.repository}"
  chart = "${each.value.chart}"
  namespace = "${each.value.namespace}"
}
