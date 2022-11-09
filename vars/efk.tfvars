namespace-name = efk
helm-application = {
  elasticsearch :{
    application-name = efk
    repository = "https://helm.elastic.co"
    chart = elasticsearch
    namespace = efk
  }
  kibana :{
    application-name = efk
    repository = "https://helm.elastic.co"
    chart = kibana
    namespace = efk
  }
  flauntd :{
    application-name = efk
    repository = "https://fluent.github.io/helm-charts"
    chart = fluent-bit
    namespace = efk
  }   
}