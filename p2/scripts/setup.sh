#!/bin/bash

sudo apt-get update
sudo apt-get install -y curl

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode=644" sh -

echo 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' >> $HOME/.bashrc
echo 'export PATH=$PATH:/usr/local/bin' >> $HOME/.bashrc

source $HOME/.bashrc

kubectl apply -n kube-system -f /vagrant/confs/app1.yaml
kubectl apply -n kube-system -f /vagrant/confs/app2.yaml
kubectl apply -n kube-system -f /vagrant/confs/app3.yaml
kubectl apply -n kube-system -f /vagrant/confs/ingress.yaml

sudo apt-get install net-tools -y
