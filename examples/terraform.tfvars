ami_id                     = "ami-3ecc8f46"
apiserver_lb_subnets       = ["subnet-0af909e620fbeecec","subnet-036ee547223d718c2","subnet-0fd3ebb3ef93a32d9",]
controlplane_instance_type = "t3.medium"
controlplane_nodes_count   = 0
controlplane_subnets       = ["subnet-0af909e620fbeecec","subnet-036ee547223d718c2","subnet-0fd3ebb3ef93a32d9",]
dns_domain_name            = "ews.works"
dns_zone_id                = "Z1NMUGQLTLR1UM"
etcd_controlplane_nodes_count                = 0
etcd_controlplane_instance_type        = "t3.large"
etcd_controlplane_subnets              = ["subnet-0af909e620fbeecec","subnet-036ee547223d718c2","subnet-0fd3ebb3ef93a32d9",]
etcd_controlplane_worker_nodes_count         = 0
etcd_controlplane_worker_instance_type = "t3.large"
etcd_controlplane_worker_subnets       = ["subnet-0af909e620fbeecec","subnet-036ee547223d718c2","subnet-0fd3ebb3ef93a32d9",]
etcd_instance_type                           = "t3.medium"
etcd_nodes_count                             = 0
etcd_subnets                                 = ["subnet-0af909e620fbeecec","subnet-036ee547223d718c2","subnet-0fd3ebb3ef93a32d9",]
ingress_lb_subnets       = ["subnet-0af909e620fbeecec","subnet-036ee547223d718c2","subnet-0fd3ebb3ef93a32d9",]
key_name                 = "garyellis"
name                     = "k8s"
tags                     = {
  owner = "garyellis"
}
vpc_id                   = "vpc-090fb2bb569edbd85"
worker_instance_type     = "t3.medium"
worker_nodes_count       = 0
worker_subnets           = ["subnet-0af909e620fbeecec","subnet-036ee547223d718c2","subnet-0fd3ebb3ef93a32d9",]