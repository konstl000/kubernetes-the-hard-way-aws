#!/bin/bash
kubectl apply -f deployment.yaml
kubectl apply -f service_CIP.yaml
kubectl apply -f ingress.yaml
