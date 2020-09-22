#!/bin/bash
function getInstancesByTag () {
 aws ec2 describe-instances --filter "Name=tag-value,Values=$1" | jq -c '.Reservations[].Instances[] | select (.State.Name == "running")'
}
function getInstanceId(){
 echo "$1" | sed -n "$2p" | jq -r '.InstanceId'
}
function copyToInstance(){
  cnt=1
  while true
  do
    rsync -rv -e "ssh -i ../rsa/k8s.pem -o StrictHostKeyChecking=no" "$1" 'ubuntu@'"$(getInstanceId "$2" "$3")"':'"$4"
    if [[ $? == 0 ]]
    then
        break
    else
        if [[ $cnt -gt 10 ]]
        then
          echo "rsync fails to often, bailing"
          break
        else
          cnt=$(($cnt+1))
          echo "$cnt attempt of rsync follows:"
        fi
    fi
  done
}
masters=$(getInstancesByTag k8smaster)
workers=$(getInstancesByTag k8snode)
for index in 1; do
  for filename in ca.pem worker-kubeflow-${index}-key.pem worker-kubeflow-${index}.pem worker-kubeflow-${index}.kubeconfig kube-proxy.kubeconfig
  do
    copyToInstance "${filename}" "$kubeflow" "$index" /home/ubuntu/
  done
done

