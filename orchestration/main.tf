module "cluster" {
  source = "../../modules/helm-release"
  name= var.name
  repository = var.repository
  chart = var.chart
  namespace = var.namespace
  create_namespace = var.create_namespace
}
