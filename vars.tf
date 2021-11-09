variable default_tags {
  type = map(string)
  default = {
            role                  = "k8s"
            environment           = "k8s_thehard_way"
            support-contact       = "none"
            tagging-version       = "1.0"
            stage                 = "DEV"
            project_name          = "k8s_the_hard_way"
  }

}
variable cidr_block {
  default = "10.200.0.0/16"
}
variable stage {
  default = "dev"
}
variable env_name {
  default = "k8s"
}
variable K8S_VERSION {
  default = "v1.22.2"
}
variable WORKER_NODE_SIZE{
  default = "t3.medium"
}
variable MASTER_NODE_SIZE{
  default = "t3.medium"
}

