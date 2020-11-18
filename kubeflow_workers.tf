module "node-kf-asg" {
  source = "../shared/modules/asg"
  cluster_name = "kubeflow"
  ssh_key_name = aws_key_pair.k8s.key_name
  default_tags = var.default_tags
  additional_tags_ec2 = {
    "Maintenance" = "${var.env_name}_${var.stage}"
    "Role"        = "k8snode"
    "kubernetes.io/cluster/kubernetes-the-hard-way" = "owned"
  }
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
  node_type = "t3.xlarge"
  node_volume_size = 60
  make_public = true
  desired_capacity = 1
  max_size = 1
  min_size = 1
  ami = data.aws_ami.ubuntu.id
  spot_price = "0.192"
  sg_ids = [module.k8snode_sg.id]
  instance_profile_name = "k8snode-kf"
  iam_role = module.k8snode_role.name
  use_inspector = false
  additional_user_data = [
    {
      filename     = "2-custom.sh"
      content_type = "text/x-shellscript"
      content      = data.template_file.k8snode.rendered
    },
    {
      filename     = "3-ssm.sh"
      content_type = "text/x-shellscript"
      content      = file("./user_data/ssm_ubuntu.sh")
    }
  ]
}

