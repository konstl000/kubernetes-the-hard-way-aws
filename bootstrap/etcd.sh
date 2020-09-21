#!/bin/bash
VERSION='3.4.13'
curl -LO https://github.com/etcd-io/etcd/releases/download/"$VERSION"/etcd-"$VERSION"-linux-amd64.tar.gz
tar -xvf etcd-"$VERSION"-linux-amd64.tar.gz
sudo mv etcd-"$VERSION"-linux-amd64/etcd* /usr/local/bin/
sudo mkdir -p /etc/etcd /var/lib/etcd
sudo cp ca.pem kubernetes-key.pem kubernetes.pem /etc/etcd/
INTERNAL_IP=$(curl 169.254.169.254/latest/meta-data/local-ipv4)
ETCD_NAME=$(curl 169.254.169.254/latest/meta-data/local-hostname)
cat <<EOF | sudo tee /etc/systemd/system/etcd.service
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
Type=notify
ExecStart=/usr/local/bin/etcd \\
  --name $ETCD_NAME \\
  --cert-file=/etc/etcd/kubernetes.pem \\
  --key-file=/etc/etcd/kubernetes-key.pem \\
  --peer-cert-file=/etc/etcd/kubernetes.pem \\
  --peer-key-file=/etc/etcd/kubernetes-key.pem \\
  --trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-client-cert-auth \\
  --client-cert-auth \\
  --initial-advertise-peer-urls https://$INTERNAL_IP:2380 \\
  --listen-peer-urls https://$INTERNAL_IP:2380 \\
  --listen-client-urls https://$INTERNAL_IP:2379,https://127.0.0.1:2379 \\
  --advertise-client-urls https://$INTERNAL_IP:2379 \\
  --initial-cluster-token etcd-cluster-0 \\
  --initial-cluster ${CONTROLLER_CONFIG} \\
  --initial-cluster-state new \\
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable etcd
sudo systemctl start etcd
sudo ETCDCTL_API=3 etcdctl member list \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.pem \
  --cert=/etc/etcd/kubernetes.pem \
  --key=/etc/etcd/kubernetes-key.pem
