data "aws_subnet" "apiserver_lb_subnets" {
  for_each = toset(var.apiserver_lb_subnets)
  id       = each.value
}

data "aws_subnet" "ingress_lb_subnets" {
  for_each = toset(var.ingress_lb_subnets)
  id       = each.value
}

locals {

  #### cloud provider tags
  cluster_id = var.cluster_id == "" ? var.name : var.cluster_id
  cluster_id_tag = {
    format("kubernetes.io/cluster/%s", local.cluster_id) = var.cluster_id_value
  }
  # empty volume tags allow ec2 instance module to ignore volumes created by aws cloud provider
  volume_tags = {
    "kubernetes.io/created-for/pv/name" = "-"
    "kubernetes.io/created-for/pvc/name" = "-"
    "kubernetes.io/created-for/pvc/namespace" = "-"
  }


  #### security group configuration

  # computed variables
  apiserver_lb_subnet_cidrs = [for i in data.aws_subnet.apiserver_lb_subnets : i.cidr_block]
  ingress_lb_subnet_cidrs   = [for i in data.aws_subnet.ingress_lb_subnets : i.cidr_block]

  # etcd static rules
  etcd_rules = [
    { desc = "etcd client ", from_port = "2379", to_port = "2379", protocol = "tcp" },
    { desc = "etcd peer", from_port = "2380", to_port = "2380", protocol = "tcp" },
    { desc = "health checks", from_port = "9099", to_port = "9099", protocol = "tcp" },
  ]
  etcd_ingress_sg_rules = [
    { desc = "apiserver etcd client ", source_security_group_id = module.controlplane_sg.security_group_id, from_port = "2379", to_port = "2379", protocol = "tcp" },
  ]

  # control plane static rules
  controlplane_rules = [
    { desc = "kubelet", from_port = "10250", to_port = "10250", protocol = "tcp" },
    { desc = "liveness probe", from_port = "10254", to_port = "10254", protocol = "tcp" },
    { desc = "apiserver nodes", from_port = "6443", to_port = "6443", protocol = "tcp" },
    { desc = "apiserver lb", from_port = "443", to_port = "443", protocol = "tcp" },
  ]
  controlplane_ingress_sg_rules = [
    { desc = "apiserver nodes", source_security_group_id = module.worker_sg.security_group_id, from_port = "6443", to_port = "6443", protocol = "tcp" },
    { desc = "workers to apiserver lb", source_security_group_id = module.worker_sg.security_group_id, from_port = "443", to_port = "443", protocol = "tcp" },
  ]
  controlplane_egress_sg_rules = [
    { desc = "etcd client ", source_security_group_id = module.etcd_sg.security_group_id, from_port = "2379", to_port = "2379", protocol = "tcp" },
  ]
  controlplane_ingress_cidr_rules = [
    { desc = "nlb health checks", from_port = "6443", to_port = "6443", protocol = "tcp", cidr_blocks = join(",", local.apiserver_lb_subnet_cidrs) },
  ]

  # worker static rules
  worker_rules = [
    { desc = "kubelet", from_port = "10250", to_port = "10250", protocol = "tcp" },
    { desc = "node port range", from_port = "30000", to_port = "32767", protocol = "tcp" },
    { desc = "node port range", from_port = "30000", to_port = "32767", protocol = "udp" },
    { desc = "nginx-ingress liveness probe", from_port = "10254", to_port = "10254", protocol = "tcp" },
  ]
  worker_egress_sg_rules = [
    { desc = "apiserver nodes", source_security_group_id = module.worker_sg.security_group_id, from_port = "6443", to_port = "6443", protocol = "tcp" },
    { desc = "apiserver lb", source_security_group_id = module.worker_sg.security_group_id, from_port = "443", to_port = "443", protocol = "tcp" },
  ]

  worker_ingress_cidr_rules = [
    { desc = "nlb health checks", from_port = "443", to_port = "443", protocol = "tcp", cidr_blocks = join(",", local.ingress_lb_subnet_cidrs) },
  ]

  # other static rules
  cni_rules = {
    calico = [
      { desc = "calico BGP", to_port = 179, from_port = 179, protocol = "tcp" },
      { desc = "calico IP-in-IP", to_port = "-1", from_port = "-1", protocol = "94" },
    ]
  }
  prometheus_rules = [
    { desc = "prometheus-kube-scheduler", from_port = "10251", to_port = "10251", protocol = "tcp" },
    { desc = "prometheus-kube-controller-manager", from_port = "10252", to_port = "10252", protocol = "tcp" },
    { desc = "prometheus-node-exporter", from_port = "9100", to_port = "9100", protocol = "tcp" },
  ]

  #### lb configuration
  apiserver_lb_listeners           = [{ port = "6443", target_group_index = "0" }, ]
  apiserver_lb_listeners_count     = 1
  apiserver_lb_target_groups       = [{ name = "6443", target_type = "ip", port = "6443", }, ]
  apiserver_lb_target_groups_count = 1
  apiserver_lb_target_group_health_checks = [
    { target_groups_index = "0", protocol = "TCP", port = "6443", interval = "10", healthy_threshold = "2", unhealthy_threshold = "2" },
  ]

  ingress_lb_listeners           = [{ port = "443", target_group_index = "0" }, ]
  ingress_lb_listeners_count     = 1
  ingress_lb_target_groups       = [{ name = "443", target_type = "ip", port = "443", }, ]
  ingress_lb_target_groups_count = 1
  ingress_lb_target_group_health_checks = [
    { target_groups_index = "0", protocol = "HTTPS", path = "/healthz", port = "443", interval = "10", healthy_threshold = "2", unhealthy_threshold = "2" },
  ]
}
