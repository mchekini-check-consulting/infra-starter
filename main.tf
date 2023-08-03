locals {
  local_data = jsondecode(file("${path.module}/config.json"))
}

module "iam" {
  source = "./modules/iam"
  environment = local.local_data.environment
}

module "aws-secret-manager" {
  source      = "./modules/secret-manager"
  environment = local.local_data.environment
}

module "s3" {
  source       = "./modules/s3"
  bucket_names = local.local_data.buckets
  environment  = local.local_data.environment
}

module "rds" {
  source      = "./modules/rds"
  environment = local.local_data.environment
  cred = {
    username : module.aws-secret-manager.db_creds.username,
    password : module.aws-secret-manager.db_creds.password
  }
  depends_on = [module.aws-secret-manager]
}

module "ec2" {
  source        = "./modules/ec2"
  ec2-instances = local.local_data.ec2Instances
  ec2_keyName   = module.aws-secret-manager.ec2_keyName
  applications  = local.local_data.applications
  hostedZone    = local.local_data.hostedZoneName
  environment   = local.local_data.environment
  instance-profile-name = module.iam.instance-profile-name
  certificate_arn = module.acm.certificate_arn
  depends_on    = [module.aws-secret-manager, module.iam, module.acm]
}

module "route53" {
  source        = "./modules/route53"
  hostedZone    = local.local_data.hostedZoneName
  alb-dns-name  = module.ec2.dns-name
  alb-zone-id   = module.ec2.zone-id
  applications  = local.local_data.applications
  depends_on    = [module.ec2]
  ec2-instances = local.local_data.ec2Instances
  ec2-ips       = module.ec2.ec2-ips
  environment   = local.local_data.environment
}

module "acm" {
  source = "./modules/acm"
  applications = local.local_data.applications
  hostedZone = local.local_data.hostedZoneName
}




#module "api-gateway" {
#  source = "./modules/api-gateway"
#}