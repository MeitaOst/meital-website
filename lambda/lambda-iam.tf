#iam policy
resource "aws_iam_role_policy" "lambda_policy" {
   name = "lambda_policy"
   role = aws_iam_role.lambda_role.id
   # Terraform's "jsonencode" function converts a
   # Terraform expression result to valid JSON syntax.
   policy = "${file("lambda/json/lambda-policy.json")}"
}

 

#iam role
resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"
  assume_role_policy = "${file("lambda/json/lambda-iam-role.json")}"
}
