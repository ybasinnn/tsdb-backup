module "s3" {
  source = "./modules/s3"

  providers = {
    aws = aws.s3
  }
}

module "vpc" {
  source = "./modules/vpc"

  providers = {
    aws = aws.ec2
  }
}

module "ec2" {
  source = "./modules/ec2"

  providers = {
    aws = aws.ec2
  }

  # Referencing the output makes the instance wait for the bucket.
  backup_bucket = module.s3.bucket_name

  vpc_id                       = module.vpc.vpc_id
  subnet_id                    = module.vpc.private_subnet_id
  ssh_source_security_group_id = module.vpc.eice_security_group_id
}
