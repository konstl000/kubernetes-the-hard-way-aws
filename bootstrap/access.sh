#!/bin/bash
MAX_ATT=60
function getNlbDNSByName(){
  aws elbv2 describe-load-balancers --names $1 | jq -r '.LoadBalancers[0].DNSName'
}
function configKubectl(){
  KUBERNETES_PUBLIC_ADDRESS=$(getNlbDNSByName k8s-nlb)
  checkIfRunning "$KUBERNETES_PUBLIC_ADDRESS"
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
function checkIfRunning(){
  attNumber=1
  while true
  do
  curl "$1"
  if [[ "$?" == 0 ]]
  then
    break
  else
    echo "The API server is not reachable yet, waiting ..."
    sleep 10
    attNumber=$((attNumber+1))
    if [[ $attNumber -gt $MAX_ATT ]]
    then
      echo "the Api server could not be reached in ${MAX_ATT} attempts, failed!"
      exit 1
    fi
  fi
  done 
}
configKubectl
kubectl get componentstatuses
kubectl apply -f config.yaml
