variable "ApiGatewayARN" {
  
}

#mail
resource "aws_lambda_function" "lambda_mail" {
  filename      = "lambda/zip/lam_mail.zip"
  function_name = "email_lambda"
  role          = "${aws_iam_role.lambda_role.arn}"
  handler       = "email_remainder.lambda_handler"
  source_code_hash = "${data.archive_file.zipit_mail.output_base64sha256}"
  runtime = "python3.8"
  }

data "archive_file" "zipit_mail" {
  type        = "zip"
  source_file = "lambda/python/email_remainder.py"
  output_path = "lambda/zip/lam_mail.zip"
}

#sms
resource "aws_lambda_function" "lambda_sms" {
  function_name = "sms_lambda"
  role          = "${aws_iam_role.lambda_role.arn}"
  handler       = "sms_reminder.lambda_handler"
  runtime = "python3.8"
  filename      = "lambda/zip/lam_sms.zip"
  source_code_hash = "${data.archive_file.zipit_sms.output_base64sha256}"
  }

data "archive_file" "zipit_sms" {
  type        = "zip"
  source_file = "lambda/python/sms_remainder.py"
  output_path = "lambda/zip/lam_sms.zip"
}


#api_handler
resource "aws_lambda_function" "lambda_api_handler" {
  function_name = "api_handler_lambda"
  role          = "${aws_iam_role.lambda_role.arn}"
  handler       = "api_hadnler.lambda_handler" 
  runtime = "python3.8"
  filename      = "lambda/zip/lam_api_handler.zip"
  source_code_hash = "${data.archive_file.zipit_api_handler.output_base64sha256}"
  }

  data "archive_file" "zipit_api_handler" {
  type        = "zip"
  source_file = "lambda/python/api_hadnler.py"
  output_path = "lambda/zip/lam_api_handler.zip"
}


#Gives Lambda function api permission to access the Lambda function.
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_api_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = var.ApiGatewayARN
}
#output to be consumed by another module
output "lambdaArn" {
  value = tostring(aws_lambda_function.lambda_api_handler.arn)
}

output "lambdaArnMail" {
  value = tostring(aws_lambda_function.lambda_mail.arn)
}

output "lambdaArnSms" {
  value = tostring(aws_lambda_function.lambda_sms.arn)
}

output "lambdaFun" {
  value = aws_lambda_function.lambda_api_handler.invoke_arn
}