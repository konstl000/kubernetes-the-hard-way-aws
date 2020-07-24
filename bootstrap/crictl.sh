#!/bin/bash
echo 'runtime-endpoint: unix:///var/run/containerd/containerd.sock
image-endpoint: unix:///var/run/containerd/containerd.sock
timeout: 10' | sudo tee /etc/crictl.yaml
