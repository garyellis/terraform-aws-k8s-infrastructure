variable "name" {
  description = "a unique identifier applied to all resources. Is the name prefix when more than one instance of a specific resource type is created"
  type        = string
  default     = "rancher"
}

variable "cluster_id" {
  description = "The kubernetes cluster id for tag kubernetes.io/cluster/{cluster_id}"
  type        = string
  default     = ""
}

variable "cluster_id_value" {
  description = "When vpc network resources are exclusive to the cluster, the value should be owned"
  default     = "shared"
}

variable "dns_domain_name" {
  description = "the route53 dns domain name"
  type        = string
}

variable "dns_zone_id" {
  description = "the route53 zone id"
  type        = string
}

variable "ami_id" {
  type    = string
  default = ""
}

variable "ami_name" {
  type    = string
  default = ""
}

variable "key_name" {
  default = ""
  type    = string
}

variable "source_dest_check" {
  description = "Enable source dest checking. Dsable for calico cni across multiple subnets"
  type        = bool
  default     = true
}

variable "userdata" {
  description = "the ec2 instance userdata script. Overrides the default userdata script"
  type        = string
  default     = ""
}

variable "etcd_nodes_count" {
  description = "the number of etcd nodes"
  type        = number
  default     = 0
}

variable "etcd_instance_type" {
  description = "The etcd nodes ec2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "etcd_root_block_device" {
  description = "The etcd nodes root ebs block device config"
  type        = list(map(string))
  default = [
    {
      volume_size = 40
    }
  ]
}

variable "etcd_subnets" {
  description = "The etcd nodes subnet ids"
  type        = list(string)
  default     = []
}

variable "controlplane_nodes_count" {
  description = "the number of control plane nodes"
  type        = number
  default     = 0
}

variable "controlplane_instance_type" {
  description = "The controlplane nodes ec2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "controlplane_root_block_device" {
  description = "The controlplane nodes root ebs block device config"
  type        = list(map(string))
  default = [
    {
      volume_size = 40
    }
  ]
}

variable "controlplane_subnets" {
  description = "The controlplane nodes subnet ids"
  type        = list(string)
  default     = []
}

variable "worker_nodes_count" {
  description = "the number of worker nodes"
  type        = number
  default     = 0
}

variable "worker_instance_type" {
  description = "The worker nodes ec2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "worker_root_block_device" {
  description = "The worker nodes root ebs block device config"
  type        = list(map(string))
  default = [
    {
      volume_size = 40
    }
  ]
}

variable "worker_subnets" {
  description = "The worker nodes subnet ids"
  type        = list(string)
  default     = []
}

variable "etcd_controlplane_nodes_count" {
  description = "The number of stacked etcd/controlplane nodes"
  type        = number
  default     = 0
}

variable "etcd_controlplane_instance_type" {
  description = "The ec2 instance type for stacked etcd/controlplane nodes"
  type        = string
  default     = "t3.large"
}

variable "etcd_controlplane_root_block_device" {
  description = "The stacked etcdcontrolplane nodes root ebs block device config"
  type        = list(map(string))
  default = [
    {
      volume_size = 40
    }
  ]
}

variable "etcd_controlplane_subnets" {
  description = "The subnet ids for stacked etcd/controlplane nodes"
  type        = list(string)
  default     = []
}


variable "etcd_controlplane_worker_nodes_count" {
  description = "The number of nodes with all roles"
  type        = number
  default     = 0
}

variable "etcd_controlplane_worker_instance_type" {
  description = "The ec2 instance type for nodes with all roles"
  type        = string
  default     = "t3.large"
}

variable "etcd_controlplane_worker_root_block_device" {
  description = "The stacked etcd/controlplane/worker nodes root ebs block device config"
  type        = list(map(string))
  default = [
    {
      volume_size = 60
    }
  ]
}

variable "etcd_controlplane_worker_subnets" {
  description = "The subnet ids for nodes with all roles"
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "The target vpc id"
  type        = string
}

variable "apiserver_lb_subnets" {
  description = "The apiserver lb subnet ids"
  type        = list(string)
  default     = []
}

variable "ingress_lb_subnets" {
  description = "The ingress lb subnet ids"
  type        = list(string)
  default     = []
}

variable "cni" {
  description = "the intended cluster cni"
  type        = string
  default     = "canal"
}

variable "security_group_attachments" {
  description = "A list of existing security groups attached to all ec2 instances"
  type        = list(string)
  default     = []
}

variable "ingress_cidr_rules" {
  description = "A list of ingress cidr rules applied to all cluster nodes"
  type        = list(map(string))
  default = [
    { desc = "ssh", from_port = "22", to_port = "22", protocol = "tcp", cidr_blocks = "0.0.0.0/0" },
    { desc = "kube-apiserver", from_port = "6443", to_port = "6443", protocol = "tcp", cidr_blocks = "0.0.0.0/0" },
    { desc = "https ingress", from_port = "443", to_port = "443", protocol = "tcp", cidr_blocks = "0.0.0.0/0" },
  ]
}

variable "egress_cidr_rules" {
  description = "A list of egress cidr rules applied to all cluster nodes"
  type        = list(map(string))
  default = [
    { desc = "http", from_port = "80", to_port = "80", protocol = "tcp", cidr_blocks = "0.0.0.0/0" },
    { desc = "https", from_port = "443", to_port = "443", protocol = "tcp", cidr_blocks = "0.0.0.0/0" },
  ]
}

variable "toggle_allow_all_ingress" {
  description = "allow ingress all ports and protocols on all cluster nodes"
  type        = bool
  default     = false
}

variable "toggle_allow_all_egress" {
  description = "allow ingress all ports and protocols on all cluster nodes"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags on all taggable resources"
  type        = map(string)
  default     = {}
}
