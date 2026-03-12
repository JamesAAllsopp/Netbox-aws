#Need to create a psycopg layer for the eventual Lambda

resource "aws_lambda_layer_version" "psycopg2_binary_lambda_layer" {
  description         = "psycopg2-binary lambda layer"
  filename            = "${path.module}/psycopg2-layer.zip"
  layer_name          = "psycopg312-tf"
  compatible_runtimes = ["python3.12"]
  source_code_hash    = filebase64sha256("${path.module}/psycopg2-layer.zip")
  compatible_architectures = ["x86_64"]
}


resource "aws_iam_role" "lambda_role" {
name   = "Lambda_Function_Role"
assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "lambda.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_policy" "iam_policy_for_lambda" {
 name         = "aws_iam_policy_for_terraform_aws_lambda_role"
 path         = "/"
 description  = "AWS IAM Policy for managing aws lambda role"
 policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": [
       "logs:CreateLogGroup",
       "logs:CreateLogStream",
       "logs:PutLogEvents"
     ],
     "Resource": "arn:aws:logs:*:*:*",
     "Effect": "Allow"
   }
 ]
}
EOF
}

#resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
# role        = aws_iam_role.lambda_role.name
# policy_arn  = aws_iam_policy.iam_policy_for_lambda.arn
#}

#Trying to create a secret policy and attach it to the role
resource "aws_iam_policy" "iam_policy_for_secrets" {
 name         = "secrets_lambda_policy"
 path         = "/"
 description  = "AWS IAM Policy for managing aws lambda role"
 policy = jsonencode({
     "Version": "2012-10-17",
     "Statement": [
             {
	       "Effect": "Allow",
	       "Action": "secretsmanager:GetSecretValue",
	       "Resource": "arn:aws:secretsmanager:${var.region}:${var.aws_account_id}:secret:${var.database_access_creds}"
	     },
             {
	       "Effect": "Allow",
	       "Action": "secretsmanager:GetSecretValue",
	       "Resource": "arn:aws:secretsmanager:${var.region}:${var.aws_account_id}:secret:${var.database_access_creds}"
	     }
     ]
     })
}

#Running into a problem with this where for_each doesn't know this far in advance what the resources will be
resource "aws_iam_role_policy_attachment" "attach_iam_secrets_policy_to_iam_role" {
 role        = aws_iam_role.lambda_role.name
 policy_arn  = aws_iam_policy.iam_policy_for_secrets.arn
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
 role        = aws_iam_role.lambda_role.name
 policy_arn  = aws_iam_policy.iam_policy_for_lambda.arn
}

#Need when we try to put the lambda in the VPC
resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

data "archive_file" "zip_the_python_code" {
 type         = "zip"
 source_dir   = "${path.module}/python/python"
  output_path = "${path.module}/python/simple-lambda.zip"
  excludes    = ["${path.module}/python/python/__pycache__"]
}

#Need to use a prebuilt layer to access secrets
#resource "aws_serverlessapplicationrepository_cloudformation_stack" "aws_secrets_extension" {
#  name           = "AWS-Parameters-and-Secrets-Lambda-Extension"
#  application_id = "arn:aws:lambda:eu-west-2:133256977650:layer:AWS-Parameters-and-Secrets-Lambda-Extension:24"
#  capabilities = [
#    "CAPABILITY_IAM"
#  ]
#}


resource "aws_lambda_function" "create_db_terraform_lambda_func" {
 filename                       = data.archive_file.zip_the_python_code.output_path
 function_name                  = "create-db"
 role                           =  aws_iam_role.lambda_role.arn
 handler                        = "create_db_lambda.lambda_handler"
 runtime                        = "python3.12"
 source_code_hash               = data.archive_file.zip_the_python_code.output_base64sha256
 timeout                        = 60
  depends_on                     = [aws_iam_role_policy_attachment.attach_iam_secrets_policy_to_iam_role,
    aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role,
    aws_iam_role_policy_attachment.lambda_vpc_access
  ]
  environment {
    variables          = {
      "RDS_ADDRESS" = "${var.rds_address}"
    }
  }
  layers        = [ "arn:aws:lambda:eu-west-2:133256977650:layer:AWS-Parameters-and-Secrets-Lambda-Extension:24", aws_lambda_layer_version.psycopg2_binary_lambda_layer.arn]
  vpc_config {
    #vpc_id             = var.vpc_id
    subnet_ids         = [var.subnet]
    security_group_ids = [var.sg_rds]
  }
}
