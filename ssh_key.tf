resource "aws_key_pair" "k8s" {
  key_name   = "k8s_key"
  public_key = file("./rsa/k8s.pem.pub")
}

