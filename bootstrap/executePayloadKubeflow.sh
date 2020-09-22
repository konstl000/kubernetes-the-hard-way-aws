#!/bin/bash
function prepareAwsCni(){
  curl -LO https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/master/config/v1.6/aws-k8s-cni.yaml
  if [[ -z "$AWS_DEFAULT_REGION" ]]
  then
    AWS_DEFAULT_REGION=$(aws configure get region)
  fi
  sed -i 's/us-west-2/'"$AWS_DEFAULT_REGION"'/g' aws-k8s-cni.yaml
  kubectl apply -f aws-k8s-cni.yaml
}
function main(){
prepareAwsCni
for index in 1; do
  HOSTNAME=$(echo "worker-kubeflow-$index")
  POD_CIDR="10.200.0.0/16"
  for filename in kube_workerContainerd.sh
  do
    getScriptName
    connectAndExecute "$(preparePayload $(echo "{\"payload\":\"${filename}\",\"background\":true,\"script_name\":\"${SCRIPT_NAME}\"}"))" "$workers" "$index" 1
  done
  for filename in crictl.sh
  do
    connectAndExecute "$(preparePayload $(echo "{\"payload\":\"${filename}\"}"))" "$workers" "$index"
  done
done
}
source ./executePayload.sh
USERNAME=ubuntu
workers=$(getInstancesByTag kubeflow)
main
