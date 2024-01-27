module "elastic-beanstalk-single-instance" {
  source = "./modules/elastic-beanstalk-single-instance/"

  region_primary = var.region_primary
  access_key     = var.access_key
  secret_key     = var.secret_key
  application    = var.application
  environment    = var.environment
}