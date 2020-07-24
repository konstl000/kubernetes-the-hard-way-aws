module "nlb" {
  source = "../shared/modules/nlb_v2"
  default_tags = var.default_tags
  name = "k8s-nlb"
  internal = false
  subnets = module.vpc.private_subnet_ids
  vpc_id = module.vpc.vpc_id
  cross_zone_lb = true
  forward_listeners = {
    "k8s-api" = jsonencode(
    {
      name = "k8s-api"
      port    = "443"
      tg_port     = "6443"
      protocol    = "TCP"
      tg_protocol   = "TCP"
      deregistration_delay = 10
      target_type = "instance"
      health_check = [{
        port = 6443
        protocol = "TCP"
        healthy_threshold = 3
        unhealthy_threshold = 3
        interval = 10
      }]
    }
    )
}
}
