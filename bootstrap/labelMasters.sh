#!/bin/bash
function getInstancesByTag () {
 aws ec2 describe-instances --filter "Name=tag-value,Values=$1" | jq -c '.Reservations[].Instances[] | select (.State.Name == "running")'
}
function getInstanceId(){
 echo "$1" | sed -n "$2p" | jq -r '.InstanceId'
}
function getPrivateDnsName(){
  echo "$1" | sed -n "$2p" | jq -r '.PrivateDnsName'
}
function labelNodeAsMaster(){
  kubectl label nodes "$1" node-role.kubernetes.io/master=""
}
masters=$(getInstancesByTag k8smaster)
workers=$(getInstancesByTag k8snode)
for index in 1 2 3; do
  labelNodeAsMaster "$(getPrivateDnsName "$masters" $index)"
done

