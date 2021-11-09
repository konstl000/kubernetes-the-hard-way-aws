#!/bin/bash
source ../common.sh
currDir="$(pwd)"
KUBE_PATH="bu4/kubernetes-the-hard-way"
function main(){
  TERRAFORM_STATE=$(getFileFromVault "${KUBE_PATH}/terraform_state")
  if [[ ! -z $TERRAFORM_STATE ]] && [[ "$TERRAFORM_STATE" != "null" ]]
  then
    mkdir -p rsa
    echo -e "$(getFileFromVault "${KUBE_PATH}/ssh_private_key")">rsa/k8s.pem
    chmod 600 rsa/k8s.pem
    echo -e "$(getFileFromVault "${KUBE_PATH}/ssh_public_key")">rsa/k8s.pem.pub
  fi
  mkdir -p kubecerts
  local k8sCheck=$(checkK8S "$currDir/kubecerts")
  if [[ "$k8sCheck" == 0 ]]
  then
    echo -e "${GREEN}Kubernetes is already up and running${DEF}"
    kubectl get no
  else
    echo -e "${RED}Kubernetes is not working${DEF}"
  fi
}
function vaultLoginLocal(){
  vault login -method oidc
}
vaultLoginLocal
#fixDNS
main
