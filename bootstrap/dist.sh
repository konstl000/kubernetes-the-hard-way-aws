#!/bin/bash
function getInstancesByTag () {
 aws ec2 describe-instances --filter "Name=tag-value,Values=$1" | jq -c '.Reservations[].Instances[] | select (.State.Name == "running")'
}
function getInstanceId(){
 echo "$1" | sed -n "$2p" | jq -r '.InstanceId' 
}
function copyToInstance(){
  rsync -rv -e "ssh -i ../rsa/k8s.pem -o StrictHostKeyChecking=no" "$1" 'ubuntu@'"$(getInstanceId "$2" "$3")"':'"$4"
}
masters=$(getInstancesByTag k8smaster)
workers=$(getInstancesByTag k8snode)

for index in 1 2 3; do
  for filename in ca.pem worker-${index}-key.pem worker-${index}.pem worker-${index}.kubeconfig kube-proxy.kubeconfig
  do
    copyToInstance "${filename}" "$workers" "$index" /home/ubuntu/
  done
  for filename in ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem service-account-key.pem service-account.pem admin.kubeconfig kube-controller-manager.kubeconfig kube-scheduler.kubeconfig encryption-config.yaml
  do
    copyToInstance "${filename}" "$masters" "$index" /home/ubuntu/
  done
done
