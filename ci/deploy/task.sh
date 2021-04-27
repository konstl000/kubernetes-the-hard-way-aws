#!/bin/bash
source repo/ci/common.sh
set -e
function main(){
  TERRAFORM_STATE=$(getFileFromVault "${KUBE_PATH}/terraform_state")
  pushd ./repo
  if [[ ! -z $TERRAFORM_STATE ]]
  then
    echo "${TERRAFORM_STATE}">terraform.tfstate
    mkdir -p rsa
    echo -e "$(getFileFromVault "${KUBE_PATH}/ssh_private_key")">rsa/k8s.pem
    chmod 600 rsa/k8s.pem
    echo -e "$(getFileFromVault "${KUBE_PATH}/ssh_public_key")">rsa/k8s.pem.pub
    getCerts
  fi
  runTerraform
  putFileToVault "${KUBE_PATH}/terraform_state" terraform.tfstate
  putFileToVault "${KUBE_PATH}/ssh_private_key" rsa/k8s.pem
  putFileToVault "${KUBE_PATH}/ssh_public_key" rsa/k8s.pem.pub
  local k8sCheck=$(checkK8S)
  if [[ "$k8sCheck" == 0 ]]
  then
    echo -e "${GREEN}Kubernetes is already up and running${DEF}"
    kubectl get no
  else
    echo -e "${YELLOW}Deploying kubernetes${DEF}"
    deployK8S
    uploadCerts
  fi
  popd
}
vaultLogin
assumeRole ${ROLE_TO_ASSUME}
#fixDNS
main
