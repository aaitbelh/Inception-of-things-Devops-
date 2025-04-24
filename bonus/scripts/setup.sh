#!/bin/bash

#install dependencies#

if ! command -v helm &>/dev/null; then
    echo "Installing helm Chart..."
    curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
    sudo apt-get install apt-transport-https --yes
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
    sudo apt-get update
    sudo apt-get install helm
else
    echo "Helm is already installed."
fi


## install gitlab chart##
echo "install gitlab chart"
if ! helm repo list | grep -q "gitlab"; then
	helm repo add gitlab https://charts.gitlab.io/
	helm repo update
fi
kubectl create namespace gitlab
kubectl create namespace dev2
kubectl config set-context --current --namespace=gitlab 
echo "install gitlab chart done"
if ! kubectl get pods -n gitlab | grep -q "gitlab"; then
    helm repo add gitlab https://charts.gitlab.io/
    helm repo update
    helm upgrade --install gitlab gitlab/gitlab \
    --timeout 600s \
    --set global.hosts.domain=localhost \
    --set global.hosts.externalIP=10.10.10.10 \
    --set certmanager-issuer.email=me@example.com
 
fi
#### get secret token for gitlab ####

echo "Gitlab token is: $(kubectl get secret gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode ; echo)"

# ### port forward to access gitlab ####
kubectl port-forward services/gitlab-nginx-ingress-controller 8082:443 -n gitlab --address="0.0.0.0"
