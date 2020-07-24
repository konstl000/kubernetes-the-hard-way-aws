#!/bin/bash
function getNlbDNSByName(){
  aws elbv2 describe-load-balancers --names $1 | jq -r '.LoadBalancers[0].DNSName'
}
function configKubectl(){
  KUBERNETES_PUBLIC_ADDRESS=$(getNlbDNSByName k8s-nlb)
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}
  kubectl config set-credentials admin \
    --client-certificate=admin.pem \
    --client-key=admin-key.pem
  kubectl config set-context kubernetes-the-hard-way \
    --cluster=kubernetes-the-hard-way \
    --user=admin
  kubectl config use-context kubernetes-the-hard-way
}
configKubectl
kubectl get componentstatuses
kubectl apply -f config.yaml
