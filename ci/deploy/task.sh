#!/bin/bash
set -e
GREEN='\e[32m'
DEF='\e[0m'
RED='\e[31m'
YELLOW='\e[93m'
function clearEnv(){
  unset AWS_ACCESS_KEY_ID
  unset AWS_SECRET_ACCESS_KEY
  unset AWS_SESSION_TOKEN
  unset AWS_EXPIRATION
}
function assumeRole(){
  CREDENTIALS=$(aws sts assume-role --role-arn $1 --role-session-name assumed-role)
  export AWS_ACCESS_KEY_ID="$(echo $CREDENTIALS | jq -r '.Credentials.AccessKeyId')"
  export AWS_SECRET_ACCESS_KEY="$(echo $CREDENTIALS | jq -r '.Credentials.SecretAccessKey')"
  export AWS_SESSION_TOKEN="$(echo $CREDENTIALS | jq -r '.Credentials.SessionToken')"
  export AWS_EXPIRATION=$(echo $CREDENTIALS | jq -r '.Credentials.Expiration')
  aws sts get-caller-identity
}
function fixDNS(){
  echo 'nameserver 8.8.8.8'>>/etc/resolv.conf
}
function runTerraform(){
  local cnt=0
  while [[ $cnt -lt ${MAX_ATTEMPTS} ]]
  do
    ./init.sh
    local res=0
    set +e
    terraform init
    res=$(($res+$?))
    terraform plan -out plan
    res=$(($res+$?))
    terraform apply plan
    res=$(($res+$?))
    set -e
    if [[ $res != 0 ]]
    then
      cnt=$(($cnt+1))
      echo -e "${YELLOW}Terraform state may be locked, new attempt in ${INTERVAL} seconds, remaining attempts: $((${MAX_ATTEMPTS}-$cnt))${DEF}"
      sleep ${INTERVAL}
    else
      echo -e "${GREEN}Terraform ran successfully"
      break
    fi
  done
}
function vaultLogin(){
  vault login -no-print -method=ldap username=${VAULT_USER}  password="${VAULT_PASSWORD}"
}
function putFileToVault(){
  vault kv put /concourse/${TEAM}/"$1" value=@"$2"
}
function getFileFromVault(){
  vault kv get -format=json /concourse/${TEAM}/"$1" | jq -r '.data.value'
}
function fixKubeconfig(){
  local adminIndex=$(cat ~/.kube/config | yq -r '.users | to_entries[] | select(.value.name=="admin") | .key')
  cat ~/.kube/config | yq -y '.users['"$adminIndex"'].user."client-certificate"="/root/admin.pem" | .users['"$adminIndex"'].user."client-key"="/root/admin-key.pem"'
}
function writeKubeconfig(){
  mkdir -p ~/.kube
  echo -e "${KUBE_CONFIG}">~/.kube/config
  echo -e "${ADMIN_CERT}">/root/admin.pem
  echo -e "${ADMIN_KEY}">/root/admin-key.pem
}
function deployK8S(){
  ./bootstrap/deploy_all.sh
  fixKubeconfig>kube.config
  putFileToVault "${KUBE_PATH}/kubeconfig" kube.config
  putFileToVault "${KUBE_PATH}/admin_cert" bootstrap/admin.pem
  putFileToVault "${KUBE_PATH}/admin_key" bootstrap/admin-key.pem
  echo -e "${GREEN}Env created successfully${DEF}"
}
function checkK8S(){
  set +e
  KUBE_CONFIG=$(getFileFromVault "${KUBE_PATH}/kubeconfig")
  ADMIN_CERT=$(getFileFromVault "${KUBE_PATH}/admin_cert")
  ADMIN_KEY=$(getFileFromVault "${KUBE_PATH}/admin_key")
  if [[ -z $KUBE_CONFIG ]] || [[ -z $ADMIN_CERT ]] || [[ -z $ADMIN_KEY ]]
  then
    echo 1
  else
    writeKubeconfig
    kubectl get no>/dev/null 2>/dev/null && echo 0 || echo 1    
  fi
}
function uploadCerts(){
  for fil in $(ls bootstrap/*.pem)
  do
    uploadCert "$fil"
  done
}
function uploadCert(){
  vaultPath=$(echo "$1" | sed -e 's`bootstrap`certificates`')
  putFileToVault "${KUBE_PATH}/$vaultPath" "$1"
}
function getCerts(){
 while read cert
 do
  echo -e "$(getFileFromVault "${KUBE_PATH}/certificates/$cert")">bootstrap/"$cert"
 done<<<"$(vault kv list -format=json /concourse/${TEAM}/${KUBE_PATH}/certificates | jq -r '.[]')"
}
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
