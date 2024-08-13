terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

}

provider "aws" {
  region = "us-east-1"
}

module "www-site" {
  source = "./modules/s3-site"
  domain = "www.wehrly.com"
  certificate_arn = "arn:aws:acm:us-east-1:428933486948:certificate/1f1c2305-429b-4889-8b08-77ce681f18b1"
}

module "eric-site" {
  source = "./modules/s3-site"
  domain = "eric.wehrly.com"

  filedir = "${path.module}/eric"
  certificate_arn = "arn:aws:acm:us-east-1:428933486948:certificate/1f1c2305-429b-4889-8b08-77ce681f18b1"
}

module "wedding-site" {
  source = "./modules/s3-site"
  domain = "huynh.wehrly.com"

  filedir = "${path.module}/wedding"
  configure_www = true
  certificate_arn = "arn:aws:acm:us-east-1:428933486948:certificate/67a70258-5001-4be7-8225-ed3540c746df"
  # certificate_arn = "arn:aws:acm:us-east-1:428933486948:certificate/45fd1980-e04c-4848-a5f4-d883e258d364"
}

module "lookbook-site" {
  source = "./modules/dummy"
}
