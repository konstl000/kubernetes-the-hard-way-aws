#!/bin/bash
kubectl -n kubernetes-dashboard get secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}') -o json | jq -r '.data.token' | base64 -d
echo -e "\n"

