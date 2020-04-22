module "aws-infrastructure" {
  source = "../"

  name   = var.name
  tags   = var.tags
  vpc_id = var.vpc_id

  # load balancer and lb dns cfg
  dns_domain_name      = var.dns_domain_name
  dns_zone_id          = var.dns_zone_id
  apiserver_lb_subnets = var.apiserver_lb_subnets
  ingress_lb_subnets   = var.ingress_lb_subnets

  # ec2 instances options
  ami_id                   = var.ami_id
  key_name                 = var.key_name
  toggle_allow_all_egress  = true
  toggle_allow_all_ingress = true

  # etcd nodes
  etcd_nodes_count   = 3
  etcd_instance_type = var.etcd_instance_type
  etcd_subnets       = var.etcd_subnets

  # controlplane nodes
  controlplane_nodes_count   = 2
  controlplane_instance_type = var.controlplane_instance_type
  controlplane_subnets       = var.controlplane_subnets

  # worker nodes
  worker_instance_type = 2
  worker_nodes_count   = var.worker_nodes_count
  worker_subnets       = var.worker_subnets

  # stacked etcd/controlplane nodes
  etcd_controlplane_nodes_count   = var.etcd_controlplane_nodes_count
  etcd_controlplane_instance_type = var.etcd_controlplane_instance_type
  etcd_controlplane_subnets       = var.etcd_controlplane_subnets

  # stacked etcd/controlplane/worker node
  etcd_controlplane_worker_nodes_count   = var.etcd_controlplane_worker_nodes_count
  etcd_controlplane_worker_instance_type = var.etcd_controlplane_worker_instance_type
  etcd_controlplane_worker_subnets       = var.etcd_controlplane_worker_subnets
}

module "stacked-etd-controlplane" {
  source = "../"

  name   = format("%s-stacked-etcd", var.name)
  tags   = var.tags
  vpc_id = var.vpc_id

  # load balancer and lb dns cfg
  dns_domain_name      = var.dns_domain_name
  dns_zone_id          = var.dns_zone_id
  apiserver_lb_subnets = var.apiserver_lb_subnets
  ingress_lb_subnets   = var.ingress_lb_subnets

  # ec2 instances options
  ami_id                   = var.ami_id
  key_name                 = var.key_name
  toggle_allow_all_egress  = true
  toggle_allow_all_ingress = true

  # stacked etcd/controlplane nodes
  etcd_controlplane_nodes_count   = 3
  etcd_controlplane_instance_type = var.etcd_controlplane_instance_type
  etcd_controlplane_subnets       = var.etcd_controlplane_subnets

  # worker nodes
  worker_instance_type = 2
  worker_nodes_count   = var.worker_nodes_count
  worker_subnets       = var.worker_subnets
}

module "stacked-etcd-controlplane-worker" {
  source = "../"

  name   = format("%s-stacked-all", var.name)
  tags   = var.tags
  vpc_id = var.vpc_id

  # load balancer and lb dns cfg
  dns_domain_name      = var.dns_domain_name
  dns_zone_id          = var.dns_zone_id
  apiserver_lb_subnets = var.apiserver_lb_subnets
  ingress_lb_subnets   = var.ingress_lb_subnets

  # ec2 instances options
  ami_id                   = var.ami_id
  key_name                 = var.key_name
  toggle_allow_all_egress  = true
  toggle_allow_all_ingress = true

  # stacked etcd/controlplane/worker node
  etcd_controlplane_worker_nodes_count   = 3
  etcd_controlplane_worker_instance_type = var.etcd_controlplane_worker_instance_type
  etcd_controlplane_worker_subnets       = var.etcd_controlplane_worker_subnets
}
