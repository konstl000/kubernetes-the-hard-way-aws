module "master-asg" {
  source = "../shared/modules/asg"
  cluster_name = "k8smasters"
  ssh_key_name = aws_key_pair.k8s.key_name
  default_tags = var.default_tags
  additional_tags_ec2 = {
    "Maintenance" = "${var.env_name}_${var.stage}"
    "Role"        = "k8smaster"
    "kubernetes.io/cluster/kubernetes-the-hard-way" = "owned"
  }
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
  node_type = "t3.medium"
  node_volume_size = 30
  make_public = true
  desired_capacity = 3
  max_size = 3
  min_size = 3
  ami = data.aws_ami.ubuntu.id
  spot_price = "0.0418"
  sg_ids = [module.k8smaster_sg.id]
  instance_profile_name = "k8smaster"
  iam_role = module.k8smaster_role.name
  use_inspector = false
  additional_user_data = [
    {
      filename     = "2-custom.sh"
      content_type = "text/x-shellscript"
      content      = data.template_file.k8smaster.rendered
    },
    {
      filename     = "3-ssm.sh"
      content_type = "text/x-shellscript"
      content      = file("./user_data/ssm_ubuntu.sh")
    }
  ]
}

