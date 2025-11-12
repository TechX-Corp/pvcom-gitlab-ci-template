role_name             = "pvcom-demo"
role_description      = "PVCom Demo Role"
create_role           = true
role_type             = "assume-role"
master_prefix         = "dso"
trusted_role_services = ["ec2.amazonaws.com"]
trusted_role_arns     = []
role_policy_arns      = []
custom_policy         = null
assume_role           = "arn:aws:iam::302010997939:role/pvcom-workload-deployment"
tags = {
  Environment = "dev"
  Project     = "PVCom"
}
