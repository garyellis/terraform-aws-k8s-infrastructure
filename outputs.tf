output "etcd_nodes" {
  value = module.etcd_nodes.aws_instances
}

output "etcd_node_ips" {
  value = module.etcd_nodes.aws_instance_private_ips
}

output "etcd_node_private_dns" {
  value = module.etcd_nodes.aws_instance_private_dns
}

output "controlplane_nodes" {
  value = module.controlplane_nodes.aws_instances
}

output "controlplane_node_ips" {
  value = module.controlplane_nodes.aws_instance_private_ips
}

output "controlplane_node_private_dns" {
  value = module.controlplane_nodes.aws_instance_private_dns
}

output "worker_nodes" {
  value = module.worker_nodes.aws_instances
}

output "worker_node_ips" {
  value = module.worker_nodes.aws_instance_private_ips
}

output "worker_node_private_dns" {
  value = module.worker_nodes.aws_instance_private_dns
}

output "etcd_controlplane_nodes" {
  value = module.etcd_controlplane_nodes.aws_instances
}

output "etcd_controlplane_node_ips" {
  value = module.etcd_controlplane_nodes.aws_instance_private_ips
}

output "etcd_controlplane_node_private_dns" {
  value = module.etcd_controlplane_nodes.aws_instance_private_dns
}

output "etcd_controlplane_worker_nodes" {
  value = module.etcd_controlplane_worker_nodes.aws_instances
}

output "etcd_controlplane_worker_node_ips" {
  value = module.etcd_controlplane_worker_nodes.aws_instance_private_ips
}

output "etcd_controlplane_worker_node_private_dns" {
  value = module.etcd_controlplane_worker_nodes.aws_instance_private_dns
}

output "apiserver_lb_zone_id" {
  value = module.apiserver_lb.lb_zone_id
}

output "apiserver_lb_dns_name" {
  value = module.apiserver_lb.lb_dns_name
}

output "apiserver_fqdn" {
  value = format("%s-apiserver.%s", var.name, var.dns_domain_name)
}

output "ingress_fqdn" {
  value = format("%s-ingress.%s", var.name, var.dns_domain_name)
}

output "apiserver_url" {
  value = format("https://%s-apiserver.%s:6443", var.name, var.dns_domain_name)
}

output "apiserver_host" {
  value = format("%s-apiserver.%s:6443", var.name, var.dns_domain_name)
}

output "ingress_lb_zone_id" {
  value = module.ingress_lb.lb_zone_id
}

output "ingress_lb_dns_name" {
  value = module.ingress_lb.lb_dns_name
}
