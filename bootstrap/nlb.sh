#!/bin/bash
function getInstanceIdsByTag () {
 aws ec2 describe-instances --filter "Name=tag-value,Values=$1" | jq -r '.Reservations[].Instances[] | select (.State.Name == "running") | "Id=\(.InstanceId)"' | xargs 
}
function getNlbArnByName(){
  aws elbv2 describe-load-balancers --names $1 | jq -r '.LoadBalancers[0].LoadBalancerArn'
}
function getNlbDNSByName(){
  aws elbv2 describe-load-balancers --names $1 | jq -r '.LoadBalancers[0].DNSName'
}
function getTargetGroup(){
  aws elbv2 describe-target-groups --load-balancer-arn $(getNlbArnByName $1) | jq -r '.TargetGroups[0].TargetGroupArn'
}
function main(){
aws elbv2 register-targets \
              --target-group-arn $(getTargetGroup "$1") \
              --targets $(getInstanceIdsByTag "$2") | sed 's/a/a/' #the sed stuff just blocks the annoying terminal blocking of aws cli v2
  local nlbDNS=$(getNlbDNSByName "$1")
  curl --cacert ca.pem https://${nlbDNS}/version
  echo -e "\n$nlbDNS"
}
main "k8s-nlb" "k8smaster"


