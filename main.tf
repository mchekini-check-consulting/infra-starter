locals {
  local_data = jsondecode(file("${path.module}/config.json"))
}

module "aws-secret-manager" {
  source = "./modules/secret-manager"
}

#module "s3" {
#  source       = "./modules/s3"
#  bucket_names = local.local_data.buckets
#  env          = local.local_data.environment
#}

#module "rds" {
#  source = "./modules/rds"
#  cred   = {
#    username : module.aws-secret-manager.db_creds.username,
#    password : module.aws-secret-manager.db_creds.password
#  }
#  depends_on = [module.aws-secret-manager]
#}



module "ec2" {
  source = "./modules/ec2"
  ec2-instances = local.local_data.ec2Instances
  ec2_keyName = module.aws-secret-manager.ec2_keyName
  applications = local.local_data.applications
  hostedZone = local.local_data.hostedZoneName
  depends_on = [module.aws-secret-manager]
}

module "route53" {
  source = "./modules/route53"
  hostedZone = local.local_data.hostedZoneName
  subdomains = local.local_data.recordsSubdomains
  alb-dns-name = module.ec2.dns-name
  alb-zone-id = module.ec2.zone-id
  applications = local.local_data.applications
  depends_on = [module.ec2]
}


#module "ap-gateway" {
#  source = "./modules/api-gateway"
#}