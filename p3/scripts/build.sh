#!/bin/bash

echo "wanna start building your environment? (y/n) | apply the configuration after building? (apply)"
read answer
if [ "$answer" != "${answer#[Yy]}" ]; then
    echo "install argocd server"
    kubectl create namespace argocd
    kubectl create namespace dev
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    sleep 10
    kubectl get pods -n argocd 
    echo "install argocd server done"

    #port forward argocd server#


    #get argocd password#
    sleep 3
    echo "do you want reveive argocd password? (y/n)"
    read answer
    if [ "$answer" != "${answer#[Yy]}" ]; then
        echo "argocd password is:"
        kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
    else
        echo "Exiting"
        exit 1
    fi
fi
if [ "$answer" = "apply" ]; then 
    echo "Before the application create a namespace dev"
    kubectl apply -f ../config/application.yaml || true
fi
echo "port forward argocd server"
kubectl port-forward svc/argocd-server -n argocd 8083:443
echo "port forward argocd server done"

