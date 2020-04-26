# terraform-aws-k8s-infrastructure
Create aws kubernetes cluster infrastructure. This modules creates the following kubernetes cluster infrastructure:

* etcd nodes with optional ec2 instance autorecovery
* control plane nodes with cloud provider iam profile and optional ec2 instance autorecovery
* worker nodes with cloud provider iam profile and optional ec2 instance autorecovery
* stacked etcd + controlplane nodes with cloud provider iam profile and optional ec2 instance autorecovery
* stacked etcd, controlplane and worker nodes with cloud provider iam profile and optional ec2 instance autorecovery
* etcd, controlplane and worker security groups and minimal set of rules
* apiserver nlb, target group and target group ec2 instance attachments
* ingress nlb, target group and target group ec2 instance attachments
* route53 private zone apias records for apiserver and ingress load balancers


## Requirements

terraform v0.12

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ami\_id | n/a | `string` | `""` | no |
| ami\_name | n/a | `string` | `""` | no |
| apiserver\_lb\_subnets | The apiserver lb subnet ids | `list(string)` | `[]` | no |
| controlplane\_instance\_type | The controlplane nodes ec2 instance type | `string` | `"t3.medium"` | no |
| controlplane\_nodes\_count | the number of control plane nodes | `number` | `0` | no |
| controlplane\_subnets | The controlplane nodes subnet ids | `list(string)` | `[]` | no |
| dns\_domain\_name | the route53 dns domain name | `string` | n/a | yes |
| dns\_zone\_id | the route53 zone id | `string` | n/a | yes |
| egress\_cidr\_rules | A list of egress cidr rules applied to all cluster nodes | `list(map(string))` | <pre>[<br>  {<br>    "cidr_blocks": "0.0.0.0/0",<br>    "desc": "http",<br>    "from_port": "80",<br>    "protocol": "tcp",<br>    "to_port": "80"<br>  },<br>  {<br>    "cidr_blocks": "0.0.0.0/0",<br>    "desc": "https",<br>    "from_port": "443",<br>    "protocol": "tcp",<br>    "to_port": "443"<br>  }<br>]</pre> | no |
| etcd\_controlplane\_instance\_type | The ec2 instance type for stacked etcd/controlplane nodes | `string` | `"t3.large"` | no |
| etcd\_controlplane\_nodes\_count | The number of stacked etcd/controlplane nodes | `number` | `0` | no |
| etcd\_controlplane\_subnets | The subnet ids for stacked etcd/controlplane nodes | `list(string)` | `[]` | no |
| etcd\_controlplane\_worker\_instance\_type | The ec2 instance type for nodes with all roles | `string` | `"t3.large"` | no |
| etcd\_controlplane\_worker\_nodes\_count | The number of nodes with all roles | `number` | `0` | no |
| etcd\_controlplane\_worker\_subnets | The subnet ids for nodes with all roles | `list(string)` | `[]` | no |
| etcd\_instance\_type | The etcd nodes ec2 instance type | `string` | `"t3.medium"` | no |
| etcd\_nodes\_count | the number of etcd nodes | `number` | `0` | no |
| etcd\_subnets | The etcd nodes subnet ids | `list(string)` | `[]` | no |
| ingress\_cidr\_rules | A list of ingress cidr rules applied to all cluster nodes | `list(map(string))` | <pre>[<br>  {<br>    "cidr_blocks": "0.0.0.0/0",<br>    "desc": "ssh",<br>    "from_port": "22",<br>    "protocol": "tcp",<br>    "to_port": "22"<br>  },<br>  {<br>    "cidr_blocks": "0.0.0.0/0",<br>    "desc": "kube-apiserver",<br>    "from_port": "6443",<br>    "protocol": "tcp",<br>    "to_port": "6443"<br>  },<br>  {<br>    "cidr_blocks": "0.0.0.0/0",<br>    "desc": "https ingress",<br>    "from_port": "443",<br>    "protocol": "tcp",<br>    "to_port": "443"<br>  }<br>]</pre> | no |
| ingress\_lb\_subnets | The ingress lb subnet ids | `list(string)` | `[]` | no |
| key\_name | n/a | `string` | `""` | no |
| name | a unique identifier applied to all resources. Is the name prefix when more than one instance of a specific resource type is created | `string` | `"rancher"` | no |
| security\_group\_attachments | A list of existing security groups attached to all ec2 instances | `list(string)` | `[]` | no |
| tags | A map of tags on all taggable resources | `map(string)` | `{}` | no |
| toggle\_allow\_all\_egress | allow ingress all ports and protocols on all cluster nodes | `bool` | `false` | no |
| toggle\_allow\_all\_ingress | allow ingress all ports and protocols on all cluster nodes | `bool` | `false` | no |
| vpc\_id | n/a | `string` | n/a | yes |
| worker\_instance\_type | The worker nodes ec2 instance type | `string` | `"t3.medium"` | no |
| worker\_nodes\_count | the number of worker nodes | `number` | `0` | no |
| worker\_subnets | The worker nodes subnet ids | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| apiserver\_fqdn | n/a |
| apiserver\_host | n/a |
| apiserver\_lb\_dns\_name | n/a |
| apiserver\_lb\_zone\_id | n/a |
| apiserver\_url | n/a |
| controlplane\_node\_ips | n/a |
| controlplane\_node\_private\_dns | n/a |
| controlplane\_nodes | n/a |
| etcd\_controlplane\_node\_ips | n/a |
| etcd\_controlplane\_node\_private\_dns | n/a |
| etcd\_controlplane\_nodes | n/a |
| etcd\_controlplane\_worker\_node\_ips | n/a |
| etcd\_controlplane\_worker\_node\_private\_dns | n/a |
| etcd\_controlplane\_worker\_nodes | n/a |
| etcd\_node\_ips | n/a |
| etcd\_node\_private\_dns | n/a |
| etcd\_nodes | n/a |
| ingress\_fqdn | n/a |
| ingress\_lb\_dns\_name | n/a |
| ingress\_lb\_zone\_id | n/a |
| worker\_node\_ips | n/a |
| worker\_node\_private\_dns | n/a |
| worker\_nodes | n/a |
