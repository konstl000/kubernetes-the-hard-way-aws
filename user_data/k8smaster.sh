#!/bin/bash
exec>>/home/ubuntu/install.log
2>&1
apt-get update -y
apt-get upgrade -y
apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
for util in kube-apiserver kube-controller-manager kube-scheduler kube-proxy kubelet kubectl
do
  echo "getting $util ..."
  curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.18.6/bin/linux/amd64/$util
  chmod +x $util
  mv $util /usr/local/bin/
done
