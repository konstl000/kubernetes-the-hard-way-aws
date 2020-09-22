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
function getPrivateDnsName(){
  echo "$1" | sed -n "$2p" | jq -r '.PrivateDnsName'
}
function getHostName(){
  echo "$1" | sed -n "$2p" | jq -r '.PrivateDnsName' | sed 's/\..*$//'
}
function getLbDNS(){
  aws elbv2 describe-load-balancers --names k8s-nlb | jq -r '.LoadBalancers[0].DNSName'
}
kubeflow=$(getInstancesByTag kubeflow)
for index in 1; do
cat > worker-kubeflow-${index}-csr.json <<EOF
{
  "CN": "system:node:$(getPrivateDnsName "${kubeflow}" ${index})",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "system:nodes",
      "OU": "Kubernetes The Hard Way",
      "ST": "Oregon"
    }
  ]
}
EOF
cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=$(getHostName "${kubeflow}" ${index}),$(getPrivateDnsName "${kubeflow}" ${index}),$(getPublicIp "${kubeflow}" ${index}),$(getPrivateIp "${kubeflow}" ${index}) \
  -profile=kubernetes \
  worker-kubeflow-${index}-csr.json | cfssljson -bare worker-kubeflow-${index}
done
