#!/bin/bash
curl -L -o nginx.yaml https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.34.1/deploy/static/provider/aws/deploy.yaml
kubectl apply -f nginx.yaml
