locals {
  aliases = { for k, v in toset(var.aliases) : k => { name = v } }
  
  aws_services = flatten([
    for v in var.aws_services : [
      format("%s.amazonaws.com", v)
    ] if length(var.aws_services) > 0
  ])
  
  kms_via_services = flatten([
    for v in var.kms_via_services : [
      format("%s.%s.amazonaws.com", v, data.aws_region.current.name)
    ] if length(var.kms_via_services) > 0
  ])
}
