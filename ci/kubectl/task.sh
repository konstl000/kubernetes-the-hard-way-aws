#!/bin/bash
source repo/ci/common.sh
function main(){
  TERRAFORM_STATE=$(getFileFromVault "${KUBE_PATH}/terraform_state")
  pushd ./repo
  if [[ ! -z $TERRAFORM_STATE ]] && [[ "$TERRAFORM_STATE" != "null" ]]
  then
    echo "${TERRAFORM_STATE}">terraform.tfstate
    mkdir -p rsa
    echo -e "$(getFileFromVault "${KUBE_PATH}/ssh_private_key")">rsa/k8s.pem
    chmod 600 rsa/k8s.pem
    echo -e "$(getFileFromVault "${KUBE_PATH}/ssh_public_key")">rsa/k8s.pem.pub
    getCerts
  fi
  local k8sCheck=$(checkK8S)
  if [[ "$k8sCheck" == 0 ]]
  then
    echo -e "${GREEN}Kubernetes is already up and running${DEF}"
    kubectl get no
  else
    echo -e "${RED}Kubernetes is not working${DEF}"
  fi
  popd
}
vaultLogin
assumeRole ${ROLE_TO_ASSUME}
#fixDNS
main
exit 1
