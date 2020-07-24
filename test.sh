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
function getHostName(){
  echo "$1" | sed -n "$2p" | jq -r '.PrivateDnsName' | sed 's/\..*$//'
}
masters=$(getInstancesByTag k8smaster)
workers=$(getInstancesByTag k8snode)
getPublicIp "$masters" 3
getHostName "$masters" 1
