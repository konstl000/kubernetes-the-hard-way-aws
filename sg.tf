module "k8smaster_sg"{
  source = "../shared/modules/sg"
  name = "k8s-master-sg"
  description = "Allow traffic to the k8s control plane"
  vpc_id = module.vpc.vpc_id
  rules = [
  jsonencode({
      type = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      source_security_group_id = null
  }),
  jsonencode({
      type = "ingress"
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      cidr_blocks = [var.cidr_block]
  }),
  jsonencode({
      type = "ingress"
      from_port   = 0
      to_port     = 65535
      protocol    = "udp"
      cidr_blocks = [var.cidr_block]
  }),
  jsonencode({
      type = "ingress"
      from_port   = 0
      to_port     = 254
      protocol    = "icmp"
      cidr_blocks = [var.cidr_block]
  }),
  jsonencode({
      type = "ingress"
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      cidr_blocks = ["10.32.0.0/24"]
  }),
  jsonencode({
      type = "ingress"
      from_port   = 0
      to_port     = 65535
      protocol    = "udp"
      cidr_blocks = ["10.32.0.0/24"]
  }),
  jsonencode({
      type = "ingress"
      from_port   = 0
      to_port     = 254
      protocol    = "icmp"
      cidr_blocks = ["10.32.0.0/24"]
  }),
  jsonencode({
      type = "ingress"
      from_port   = 6443
      to_port     = 6443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  })
]
  tags = merge({
  "Name" = "SG k8s master"
  "kubernetes.io/cluster/kubernetes-the-hard-way" = "owned"
},var.default_tags)
}
module "k8snode_sg"{
  source = "../shared/modules/sg"
  name = "k8s-node-sg"
  description = "Allow traffic to the k8s control plane"
  vpc_id = module.vpc.vpc_id
  rules = [
  jsonencode({
      type = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      source_security_group_id = null
  }),
  jsonencode({
      type = "ingress"
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      cidr_blocks = [var.cidr_block]
  }),
  jsonencode({
      type = "ingress"
      from_port   = 0
      to_port     = 65535
      protocol    = "udp"
      cidr_blocks = [var.cidr_block]
  }),
  jsonencode({
      type = "ingress"
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      cidr_blocks = ["10.32.0.0/24"]
  }),
  jsonencode({
      type = "ingress"
      from_port   = 0
      to_port     = 65535
      protocol    = "udp"
      cidr_blocks = ["10.32.0.0/24"]
  }),
  jsonencode({
      type = "ingress"
      from_port   = 0
      to_port     = 254
      protocol    = "icmp"
      cidr_blocks = ["10.32.0.0/24"]
  }),
  jsonencode({
      type = "ingress"
      from_port   = 0
      to_port     = 254
      protocol    = "icmp"
      cidr_blocks = [var.cidr_block]
  })
]
  tags = merge({
  "Name" = "SG k8s node"
  "kubernetes.io/cluster/kubernetes-the-hard-way" = "owned"
},var.default_tags)
}

