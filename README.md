# EFK hosted on kubernetes

### Branches: 
- **```main```** : We have the README.md file which is a knowldege base for this repository 
  <br>

- **```failed-orchestration-attemt```** : Failed-orchestration-attemt branch contains the terraform module structure for automating the helm charts install, it is a best approach to install the helm charts as i am creating a module which taked entries from a map to install the helm charts, we can re-use the same module for N number of charts. Unfortunatly i dont have enough time to spend on assignment due to my existing commitments at work and the approach is throwing unresolved errors.
  <br>
- **```install-with-helm```** :  This branch contains terraform configs that are successfully creating the EFK stack. 
  <br>
- **```install-with-menifest```** :  This Branch is successfully creating EFK stack using kubernets menifest files.

<br>

### Install pre-requisites for minikube
- Install Homebrew on MAC for installing the other packages and utilities at later stage, please follow this [link](https://brew.sh/) 
- Install Docker for MAC, Please follow the documentation on this [link](https://docs.docker.com/desktop/install/mac-install/)  
- Install minikube using brew command ```brew install minikube```
- Install kubectl to interact with Kuberneets cluster using Homebrew ``` brew install kubectl ```

<br>

### Steps to start minikube cluster
- Ensure all the pre-requisites are installed
- Start the docker process on MAC and allow required priviliges
- run ```minikube start```
- verify minikube status using ``` minikube status``` and it should show you an output like below
  ```
  minikube status
  minikube
  type: Control Plane
  host: Running
  kubelet: Running
  apiserver: Running
  kubeconfig: Configured
  ```

<br>

### Steps to provision elasticsearch, FlauntD and Kibana on minikube cluster using install-with-helm branch
- clone this repository on local and switch to branch install-with-helm
- update the minikube kubeconfig file in .kube/config 
- run ```terraform init ```
- run ```terraform plan ```
- run ```terraform apply```
- run ```kubectl port-forward service/kibana-kibana 5601 -n efk```
- goto browser and navigate to *http://127.0.0.1:5601/*
- execute below command and code for another terminal window, it will setup Index lifecycle managemnt rule


```

kubectl port-forward service/elasticsearch-master 9200 -n efk 
 curl -X PUT "localhost:9200/_ilm/policy/my_policy?pretty" -H 'Content-Type: application/json' -d'
{
  "policy": {
    "phases": {
      "warm": {
        "min_age": "2d",
        "actions": {
          "forcemerge": {
            "max_num_segments": 1
          }
        }
      },
      "delete": {
        "min_age": "2d",
        "actions": {
          "delete": {}
        }
      }
    }
  }
}
'
```
<br>

## Steps to provision elasticsearch, FlauntD and Kibana on minikube cluster using install-with-menifest branch
- Clone this repository on local and switch to branch install-with-menifest
- run ```terraform init```
- run ```terraform plan``` and review the resource creation
- run ```terraform apply``` to create the resources
- follow last 3 steps of install-with-helm branch to setup retention policy. 
> **_NOTE:_** if needed we can also use kubectl apply as we have the kubernetes manifest in this branch.
- 










