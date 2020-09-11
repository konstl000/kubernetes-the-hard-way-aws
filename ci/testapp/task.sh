#!/bin/bash
function fixDNS(){
  echo 'nameserver 8.8.8.8'>>/etc/resolv.conf
}
function writeKubeconfig(){
  mkdir -p ~/.kube
  echo -e "${KUBE_CONFIG}">~/.kube/config
  echo -e "${ADMIN_CERT}">/root/admin.pem
  echo -e "${ADMIN_KEY}">/root/admin-key.pem
}
function main(){
  pushd repo/test
  ./ingress.sh
  popd
}
fixDNS
writeKubeconfig
main
