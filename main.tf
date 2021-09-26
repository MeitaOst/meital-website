
provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

module "awslambdafunc" {
  source = "./lambda"
  ApiGatewayARN = module.awsApiGateway.ApiGatewayARN

  }

module "awsStepfun" {
  source = "./stepFun"
  lambdaArn = module.awslambdafunc.lambdaArn
  lambdaArnMail = module.awslambdafunc.lambdaArnMail
  lambdaArnSms = module.awslambdafunc.lambdaArnSms
  }

module "awsApiGateway" {
  source = "./apiGateway"
  lambdaFun = module.awslambdafunc.lambdaFun
  }


module "s3" {
  source = "./s3"
  }
