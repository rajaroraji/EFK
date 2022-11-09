provider "kubernetes" {
  config_path    = "~/.kube/config"
}



resource "kubernetes_stateful_set" "es_cluster" {
  metadata {
    name      = "es-cluster"
    namespace = "efk1"
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "elasticsearch"
      }
    }

    template {
      metadata {
        labels = {
          app = "elasticsearch"
        }
      }

      spec {
        init_container {
          name    = "fix-permissions"
          image   = "busybox"
          command = ["sh", "-c", "chown -R 1000:1000 /usr/share/elasticsearch/data"]

          volume_mount {
            name       = "data"
            mount_path = "/usr/share/elasticsearch/data"
          }

          security_context {
            privileged = true
          }
        }

        init_container {
          name    = "increase-vm-max-map"
          image   = "busybox"
          command = ["sysctl", "-w", "vm.max_map_count=262144"]

          security_context {
            privileged = true
          }
        }

        init_container {
          name    = "increase-fd-ulimit"
          image   = "busybox"
          command = ["sh", "-c", "ulimit -n 65536"]

          security_context {
            privileged = true
          }
        }

        container {
          name  = "elasticsearch"
          image = "docker.elastic.co/elasticsearch/elasticsearch:7.2.0"

          port {
            name           = "rest"
            container_port = 9200
            protocol       = "TCP"
          }

          port {
            name           = "inter-node"
            container_port = 9300
            protocol       = "TCP"
          }

          env {
            name  = "cluster.name"
            value = "k8s-logs"
          }

          env {
            name = "node.name"

            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }

          env {
            name  = "discovery.seed_hosts"
            value = "es-cluster-0.elasticsearch,es-cluster-1.elasticsearch,es-cluster-2.elasticsearch"
          }

          env {
            name  = "cluster.initial_master_nodes"
            value = "es-cluster-0,es-cluster-1,es-cluster-2"
          }

          env {
            name  = "ES_JAVA_OPTS"
            value = "-Xms512m -Xmx512m"
          }

          resources {
            limits = {
              cpu = "1"
            }

            requests = {
              cpu = "100m"
            }
          }

          volume_mount {
            name       = "data"
            mount_path = "/usr/share/elasticsearch/data"
          }
        }
      }
    }

    volume_claim_template {
      metadata {
        name = "data"

        labels = {
          app = "elasticsearch"
        }
      }

      spec {
        access_modes = ["ReadWriteOnce"]

        resources {
          requests = {
            storage = "5Gi"
          }
        }

        storage_class_name = "standard"
      }
    }

    service_name = "elasticsearch"
  }
}

resource "kubernetes_service" "elasticsearch" {
  metadata {
    name      = "elasticsearch"
    namespace = "efk1"

    labels = {
      app = "elasticsearch"
    }
  }

  spec {
    port {
      name = "rest"
      port = 9200
    }

    port {
      name = "inter-node"
      port = 9300
    }

    selector = {
      app = "elasticsearch"
    }

    cluster_ip = "None"
  }
}

resource "kubernetes_service_account" "fluentd" {
  metadata {
    name      = "fluentd"
    namespace = "efk1"

    labels = {
      app = "fluentd"
    }
  }
}

resource "kubernetes_cluster_role" "fluentd" {
  metadata {
    name = "fluentd"

    labels = {
      app = "fluentd"
    }
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["pods", "namespaces"]
  }
}

resource "kubernetes_cluster_role_binding" "fluentd" {
  metadata {
    name = "fluentd"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "fluentd"
    namespace = "efk1"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "fluentd"
  }
}

resource "kubernetes_daemonset" "fluentd" {
  metadata {
    name      = "fluentd"
    namespace = "efk1"

    labels = {
      app = "fluentd"
    }
  }

  spec {
    selector {
      match_labels = {
        app = "fluentd"
      }
    }

    template {
      metadata {
        labels = {
          app = "fluentd"
        }
      }

      spec {
        volume {
          name = "varlog"

          host_path {
            path = "/var/log"
          }
        }

        volume {
          name = "varlibdockercontainers"

          host_path {
            path = "/var/lib/docker/containers"
          }
        }

        container {
          name  = "fluentd"
          image = "fluent/fluentd-kubernetes-daemonset:v1.4.2-debian-elasticsearch-1.1"

          env {
            name  = "FLUENT_ELASTICSEARCH_HOST"
            value = "elasticsearch.efk1.svc.cluster.local"
          }

          env {
            name  = "FLUENT_ELASTICSEARCH_PORT"
            value = "9200"
          }

          env {
            name  = "FLUENT_ELASTICSEARCH_SCHEME"
            value = "http"
          }

          env {
            name  = "FLUENTD_SYSTEMD_CONF"
            value = "disable"
          }

          resources {
            limits = {
              memory = "512Mi"
            }

            requests = {
              cpu = "100m"

              memory = "200Mi"
            }
          }

          volume_mount {
            name       = "varlog"
            mount_path = "/var/log"
          }

          volume_mount {
            name       = "varlibdockercontainers"
            read_only  = true
            mount_path = "/var/lib/docker/containers"
          }
        }

        termination_grace_period_seconds = 30
        service_account_name             = "fluentd"

        toleration {
          key    = "node-role.kubernetes.io/master"
          effect = "NoSchedule"
        }
      }
    }
  }
}

resource "kubernetes_service" "kibana" {
  metadata {
    name      = "kibana"
    namespace = "efk1"

    labels = {
      app = "kibana"
    }
  }

  spec {
    port {
      port = 5601
    }

    selector = {
      app = "kibana"
    }
  }
}

resource "kubernetes_deployment" "kibana" {
  metadata {
    name      = "kibana"
    namespace = "efk1"

    labels = {
      app = "kibana"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "kibana"
      }
    }

    template {
      metadata {
        labels = {
          app = "kibana"
        }
      }

      spec {
        container {
          name  = "kibana"
          image = "docker.elastic.co/kibana/kibana:7.2.0"

          port {
            container_port = 5601
          }

          env {
            name  = "ELASTICSEARCH_URL"
            value = "http://elasticsearch:9200"
          }

          resources {
            limits = {
              cpu = "1"
            }

            requests = {
              cpu = "100m"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_namespace" "efk_1" {
  metadata {
    name = "efk1"
  }
}

