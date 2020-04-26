module "etcd_sg" {
  source = "github.com/garyellis/tf_module_aws_security_group?ref=v0.2.0"

  description                  = format("%s etcd role", var.name)
  name                         = format("%s-etcd", var.name)
  self_security_group_rules    = local.etcd_rules
  ingress_security_group_rules = local.etcd_ingress_sg_rules
  vpc_id                       = var.vpc_id
  tags                         = var.tags
}

module "controlplane_sg" {
  source = "github.com/garyellis/tf_module_aws_security_group?ref=v0.2.1"

  description                  = format("%s controlplane role", var.name)
  name                         = format("%s-controlplane", var.name)
  self_security_group_rules    = local.controlplane_rules
  ingress_security_group_rules = local.controlplane_ingress_sg_rules
  egress_security_group_rules  = local.controlplane_egress_sg_rules
  ingress_cidr_rules           = local.controlplane_ingress_cidr_rules
  vpc_id                       = var.vpc_id
  tags                         = var.tags
}

module "worker_sg" {
  source = "github.com/garyellis/tf_module_aws_security_group?ref=v0.2.1"

  description                 = format("%s worker role", var.name)
  name                        = format("%s-worker", var.name)
  self_security_group_rules   = local.worker_rules
  egress_security_group_rules = local.worker_egress_sg_rules
  ingress_cidr_rules          = local.worker_ingress_cidr_rules
  vpc_id                      = var.vpc_id
  tags                        = var.tags
}

module "all_sg" {
  source = "github.com/garyellis/tf_module_aws_security_group?ref=v0.2.1"

  description = format("%s all roles", var.name)
  name        = format("%s-all", var.name)
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, local.cluster_id_tag)
  self_security_group_rules = concat(
    local.cni_rules["calico"],
    local.prometheus_rules,
    list({ desc = "kubelet", from_port = "10250", to_port = "10250", protocol = "tcp" }),
    list({ desc = "apiserver", from_port = "6443", to_port = "6443", protocol = "tcp" }),
  )
  ingress_cidr_rules = var.ingress_cidr_rules
  egress_cidr_rules  = var.egress_cidr_rules


  toggle_allow_all_ingress = var.toggle_allow_all_ingress
  toggle_allow_all_egress  = var.toggle_allow_all_egress
}


module "iam_roles" {
  source = "github.com/garyellis/tf_module_aws_iam_role_k8s"

  name = var.name
}


module "apiserver_lb" {
  source = "github.com/garyellis/tf_module_aws_nlb"

  name                       = format("%s-apiserver", var.name)
  enable_deletion_protection = false
  internal                   = true
  listeners_count            = local.apiserver_lb_listeners_count
  listeners                  = local.apiserver_lb_listeners
  subnets                    = var.apiserver_lb_subnets
  target_groups_count        = local.apiserver_lb_target_groups_count
  target_groups              = local.apiserver_lb_target_groups
  target_group_health_checks = local.apiserver_lb_target_group_health_checks
  vpc_id                     = var.vpc_id
  tags                       = var.tags
}

resource "aws_lb_target_group_attachment" "apiserver_lb" {
  count            = var.controlplane_nodes_count
  target_group_arn = module.apiserver_lb.target_group_arns[0]
  target_id        = module.controlplane_nodes.aws_instance_private_ips[count.index]
}

resource "aws_lb_target_group_attachment" "apiserver_lb_etcd_controlplane" {
  count            = var.etcd_controlplane_nodes_count
  target_group_arn = module.apiserver_lb.target_group_arns[0]
  target_id        = module.etcd_controlplane_nodes.aws_instance_private_ips[count.index]
}

resource "aws_lb_target_group_attachment" "apiserver_lb_etcd_controlplane_worker" {
  count            = var.etcd_controlplane_worker_nodes_count
  target_group_arn = module.apiserver_lb.target_group_arns[0]
  target_id        = module.etcd_controlplane_worker_nodes.aws_instance_private_ips[count.index]
}


module "ingress_lb" {
  source = "github.com/garyellis/tf_module_aws_nlb"

  name                       = format("%s-ingress", var.name)
  enable_deletion_protection = false
  internal                   = true
  listeners_count            = local.ingress_lb_listeners_count
  listeners                  = local.ingress_lb_listeners
  subnets                    = var.ingress_lb_subnets
  target_groups_count        = local.ingress_lb_target_groups_count
  target_groups              = local.ingress_lb_target_groups
  target_group_health_checks = local.ingress_lb_target_group_health_checks
  vpc_id                     = var.vpc_id
  tags                       = var.tags
}

resource "aws_lb_target_group_attachment" "ingress_lb" {
  count            = var.worker_nodes_count
  target_group_arn = module.ingress_lb.target_group_arns[0]
  target_id        = module.worker_nodes.aws_instance_private_ips[count.index]
}

resource "aws_lb_target_group_attachment" "ingress_lb_controlplane" {
  count            = var.controlplane_nodes_count
  target_group_arn = module.ingress_lb.target_group_arns[0]
  target_id        = module.controlplane_nodes.aws_instance_private_ips[count.index]
}

resource "aws_lb_target_group_attachment" "ingress_lb_etcd_controlplane_worker" {
  count            = var.etcd_controlplane_worker_nodes_count
  target_group_arn = module.ingress_lb.target_group_arns[0]
  target_id        = module.etcd_controlplane_worker_nodes.aws_instance_private_ips[count.index]
}

module "lb_dns" {
  source = "github.com/garyellis/tf_module_aws_route53_zone"

  create_zone = false
  name        = var.dns_domain_name
  alias_records = [
    { name = format("%s-apiserver", var.name), aws_dns_name = module.apiserver_lb.lb_dns_name, zone_id = module.apiserver_lb.lb_zone_id, evaluate_target_health = "true" },
    { name = format("%s-ingress", var.name), aws_dns_name = module.ingress_lb.lb_dns_name, zone_id = module.ingress_lb.lb_zone_id, evaluate_target_health = "true" },
  ]
  alias_records_count = 2
  zone_id             = var.dns_zone_id
}


locals {
  userdata_script = templatefile("${path.module}/userdata.tmpl", {})
}

module "userdata" {
  source = "github.com/garyellis/tf_module_cloud_init?ref=v0.2.3"

  base64_encode          = false
  gzip                   = false
  install_docker         = true
  install_docker_compose = false
  extra_user_data_script = local.userdata_script
}

module "etcd_nodes" {
  source = "github.com/garyellis/tf_module_aws_instance?ref=v1.3.1"

  name                        = format("%s-etcd", var.name)
  count_instances             = var.etcd_nodes_count
  ami_id                      = var.ami_id
  ami_name                    = var.ami_name
  instance_type               = var.etcd_instance_type
  user_data                   = module.userdata.cloudinit_userdata
  associate_public_ip_address = false
  iam_instance_profile        = ""
  key_name                    = var.key_name
  source_dest_check           = false
  security_group_attachments  = concat(list(module.etcd_sg.security_group_id, module.all_sg.security_group_id), var.security_group_attachments)
  subnet_ids                  = var.etcd_subnets
  tags                        = merge(var.tags, local.cluster_id_tag)
}

module "controlplane_nodes" {
  source = "github.com/garyellis/tf_module_aws_instance?ref=v1.3.1"

  name                        = format("%s-controlplane", var.name)
  count_instances             = var.controlplane_nodes_count
  ami_id                      = var.ami_id
  ami_name                    = var.ami_name
  user_data                   = module.userdata.cloudinit_userdata
  instance_type               = var.controlplane_instance_type
  associate_public_ip_address = false
  iam_instance_profile        = module.iam_roles.controlplane.name
  key_name                    = var.key_name
  source_dest_check           = false
  security_group_attachments  = concat(list(module.controlplane_sg.security_group_id, module.all_sg.security_group_id), var.security_group_attachments)
  subnet_ids                  = var.controlplane_subnets
  tags                        = merge(var.tags, local.cluster_id_tag)
}

module "worker_nodes" {
  source = "github.com/garyellis/tf_module_aws_instance?ref=v1.3.1"

  name                        = format("%s-worker", var.name)
  count_instances             = var.worker_nodes_count
  ami_id                      = var.ami_id
  ami_name                    = var.ami_name
  user_data                   = module.userdata.cloudinit_userdata
  instance_type               = var.worker_instance_type
  associate_public_ip_address = false
  iam_instance_profile        = module.iam_roles.worker.name
  key_name                    = var.key_name
  source_dest_check           = false
  security_group_attachments  = concat(list(module.worker_sg.security_group_id, module.all_sg.security_group_id), var.security_group_attachments)
  subnet_ids                  = var.worker_subnets
  tags                        = merge(var.tags, local.cluster_id_tag)
}

#### stacked etcd/controlplane nodes
module "etcd_controlplane_nodes" {
  source = "github.com/garyellis/tf_module_aws_instance?ref=v1.3.1"

  name                        = format("%s-etcd-controlplane", var.name)
  count_instances             = var.etcd_controlplane_nodes_count
  ami_id                      = var.ami_id
  ami_name                    = var.ami_name
  user_data                   = module.userdata.cloudinit_userdata
  instance_type               = var.etcd_controlplane_instance_type
  associate_public_ip_address = false
  iam_instance_profile        = module.iam_roles.controlplane.name
  key_name                    = var.key_name
  security_group_attachments  = concat(list(module.etcd_sg.security_group_id, module.controlplane_sg.security_group_id, module.all_sg.security_group_id), var.security_group_attachments)
  subnet_ids                  = var.etcd_controlplane_subnets
  tags                        = merge(var.tags, local.cluster_id_tag)
}

#### nodes with etcd,controlplane,worker roles
module "etcd_controlplane_worker_nodes" {
  source = "github.com/garyellis/tf_module_aws_instance?ref=v1.3.1"

  name                        = format("%s-etcd-controlplane-worker", var.name)
  count_instances             = var.etcd_controlplane_worker_nodes_count
  ami_id                      = var.ami_id
  ami_name                    = var.ami_name
  user_data                   = module.userdata.cloudinit_userdata
  instance_type               = var.etcd_controlplane_worker_instance_type
  associate_public_ip_address = false
  iam_instance_profile        = module.iam_roles.controlplane.name
  key_name                    = var.key_name
  security_group_attachments  = concat(list(module.etcd_sg.security_group_id, module.controlplane_sg.security_group_id, module.worker_sg.security_group_id, module.all_sg.security_group_id), var.security_group_attachments)
  subnet_ids                  = var.etcd_controlplane_worker_subnets
  tags                        = merge(var.tags, local.cluster_id_tag)
}
