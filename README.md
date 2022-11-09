# EFK hosted on kubernetes

## Installing pre-requisites for minikube
- Install Homebrew on MAC for installing the other packages and utilities at later stage, please follow this [link](https://brew.sh/) 
- Install Docker for MAC, Please follow the documentation on this [link](https://docs.docker.com/desktop/install/mac-install/)  
- Install minikube using brew command ```brew install minikube```
- Install kubectl to interact with Kuberneets cluster using Homebrew ``` brew install kubectl ```


## Steps to start minikube cluster
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

## Steps to provision elasticsearch, FlauntD and Kibana on minikube cluster
-
-
-

