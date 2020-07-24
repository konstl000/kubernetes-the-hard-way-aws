#!/bin/bash
function getInstancesByTag () {
 aws ec2 describe-instances --filter "Name=tag-value,Values=$1" | jq -c '.Reservations[].Instances[] | select (.State.Name == "running")'
}
function getPublicIp(){
  echo "$1" | sed -n "$2p" | jq -r '.PublicIpAddress'
}
function getPrivateIp(){
  echo "$1" | sed -n "$2p" | jq -r '.PrivateIpAddress'
}
function getPrivateDnsName(){
  echo "$1" | sed -n "$2p" | jq -r '.PrivateDnsName'
}
function getLbDNS(){
  aws elbv2 describe-load-balancers --names k8s-nlb | jq -r '.LoadBalancers[0].DNSName'
}
function getHostName(){
  echo "$1" | sed -n "$2p" | jq -r '.PrivateDnsName' | sed 's/\..*$//'
}
masters=$(getInstancesByTag k8smaster)
workers=$(getInstancesByTag k8snode)
KUBERNETES_PUBLIC_ADDRESS=$(getLbDNS)
function getWorkerConfigs(){
  for index in 1 2 3; do
    kubectl config set-cluster kubernetes-the-hard-way \
      --certificate-authority=ca.pem \
      --embed-certs=true \
      --server=https://${KUBERNETES_PUBLIC_ADDRESS} \
      --kubeconfig=worker-${index}.kubeconfig
    kubectl config set-credentials system:node:$(getPrivateDnsName "${workers}" ${index}) \
      --client-certificate=worker-${index}.pem \
      --client-key=worker-${index}-key.pem \
      --embed-certs=true \
      --kubeconfig=worker-${index}.kubeconfig
    kubectl config set-context default \
      --cluster=kubernetes-the-hard-way \
      --user=system:node:$(getPrivateDnsName "${workers}" ${index}) \
      --kubeconfig=worker-${index}.kubeconfig
    kubectl config use-context default --kubeconfig=worker-${index}.kubeconfig
  done
}
function getKubeProxyConfig(){
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS} \
    --kubeconfig=kube-proxy.kubeconfig
  kubectl config set-credentials system:kube-proxy \
    --client-certificate=kube-proxy.pem \
    --client-key=kube-proxy-key.pem \
    --embed-certs=true \
    --kubeconfig=kube-proxy.kubeconfig
  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-proxy \
    --kubeconfig=kube-proxy.kubeconfig
  kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig
}
function getKubeControllerManagerConfig(){
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config set-credentials system:kube-controller-manager \
    --client-certificate=kube-controller-manager.pem \
    --client-key=kube-controller-manager-key.pem \
    --embed-certs=true \
    --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-controller-manager \
    --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config use-context default --kubeconfig=kube-controller-manager.kubeconfig
}
function getKubeSchedulerConfig(){
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=kube-scheduler.kubeconfig
  kubectl config set-credentials system:kube-scheduler \
    --client-certificate=kube-scheduler.pem \
    --client-key=kube-scheduler-key.pem \
    --embed-certs=true \
    --kubeconfig=kube-scheduler.kubeconfig
  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-scheduler \
    --kubeconfig=kube-scheduler.kubeconfig
  kubectl config use-context default --kubeconfig=kube-scheduler.kubeconfig
}
function getKubeAdminConfig(){
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=admin.kubeconfig
  kubectl config set-credentials admin \
    --client-certificate=admin.pem \
    --client-key=admin-key.pem \
    --embed-certs=true \
    --kubeconfig=admin.kubeconfig
  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=admin \
    --kubeconfig=admin.kubeconfig
  kubectl config use-context default --kubeconfig=admin.kubeconfig
}

getWorkerConfigs
getKubeProxyConfig
getKubeControllerManagerConfig
getKubeSchedulerConfig
getKubeAdminConfig

