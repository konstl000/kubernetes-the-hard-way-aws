#!/bin/bash
wdir="$(cd "$(dirname $0)" && pwd)"
mkdir -p "$wdir"/rsa
fname="k8s"
openssl genrsa -out "$wdir/rsa/$fname.pem" 4096
ssh-keygen -f "$wdir/rsa/$fname.pem" -y > "$wdir/rsa/$fname.pem.pub"

