
variable "lambdaFun" {
  
}
resource "aws_api_gateway_rest_api" "reminders" {

  name = "reminders"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "resource" {
  rest_api_id   = aws_api_gateway_rest_api.reminders.id
  parent_id   = aws_api_gateway_rest_api.reminders.root_resource_id
  path_part   = "resource"
}

resource "aws_api_gateway_method" "method_post" {
  rest_api_id   = aws_api_gateway_rest_api.reminders.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "POST"
  authorization = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.reminders.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.method_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambdaFun
}

resource "aws_api_gateway_deployment" "api_gateway_deploy" {
  rest_api_id = aws_api_gateway_rest_api.reminders.id
}

resource "aws_api_gateway_stage" "prod_stage" {
    rest_api_id = aws_api_gateway_rest_api.reminders.id
  deployment_id = aws_api_gateway_deployment.api_gateway_deploy.id
  stage_name    = "prod"
}

#https://17g4izjnu9.execute-api.us-east-2.amazonaws.com/prod
output "ApiGatewayARN" {
  value = tostring(aws_api_gateway_rest_api.reminders.arn)
}