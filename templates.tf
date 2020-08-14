data "template_file" "k8smaster" {
  template= file("./user_data/k8smaster.sh")
  vars = {
    K8S_VERSION = var.K8S_VERSION
  }
}

data "template_file" "k8snode" {
  template= file("./user_data/k8snode.sh")
  vars = {
    K8S_VERSION = var.K8S_VERSION
  }
}

