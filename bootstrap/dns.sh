#!/bin/bash
curl -LO https://raw.githubusercontent.com/coredns/deployment/master/kubernetes/coredns.yaml.sed
sed 's/CLUSTER_DNS_IP/10.32.0.10/g' coredns.yaml.sed>coredns.yaml
sed -i 's`UPSTREAMNAMESERVER`/etc/resolv.conf`g' coredns.yaml
sed -i 's/CLUSTER_DOMAIN REVERSE_CIDRS/cluster.local in-addr.arpa ip6.arpa/g' coredns.yaml
sed -i 's/STUBDOMAINS//g' coredns.yaml
kubectl apply -f coredns.yaml
