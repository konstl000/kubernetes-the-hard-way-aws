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
kubeflow=$(getInstancesByTag kubeflow)
KUBERNETES_PUBLIC_ADDRESS=$(getLbDNS)
function getWorkerConfigs(){
  for index in 1; do
    rm -f worker-kubeflow-${index}.kubeconfig
    kubectl config set-cluster kubernetes-the-hard-way \
      --certificate-authority=ca.pem \
      --embed-certs=true \
      --server=https://${KUBERNETES_PUBLIC_ADDRESS} \
      --kubeconfig=worker-kubeflow-${index}.kubeconfig
    kubectl config set-credentials system:node:$(getPrivateDnsName "${kubeflow}" ${index}) \
      --client-certificate=worker-kubeflow-${index}.pem \
      --client-key=worker-kubeflow-${index}-key.pem \
      --embed-certs=true \
      --kubeconfig=worker-kubeflow-${index}.kubeconfig
    kubectl config set-context default \
      --cluster=kubernetes-the-hard-way \
      --user=system:node:$(getPrivateDnsName "${kubeflow}" ${index}) \
      --kubeconfig=worker-kubeflow-${index}.kubeconfig
    kubectl config use-context default --kubeconfig=worker-kubeflow-${index}.kubeconfig
  done
}

