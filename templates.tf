data "template_file" "k8smaster" {
  template= file("./user_data/k8smaster.sh")
  vars = {
  }
}

data "template_file" "k8snode" {
  template= file("./user_data/k8snode.sh")
  vars = {
  }
}

