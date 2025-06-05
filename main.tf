provider "aws" {
  region = "eu-west-1"
}

module "iam" {
  source           = "./modules/iam_role"
  lambda_role_name = "ec2-fghj-role"
}

module "start_lambda" {
  source           = "./modules/lambda_function"
  function_name    = "StartEC2Instances"
  handler_file     = "${path.module}/start_lambda.py"
  handler_name     = "start_lambda.lambda_handler"
  role_arn         = module.iam.lambda_role_arn
  environment_vars = {
    INSTANCE_IDS = "i-0169a79a8eb7421ef"
  }
}

module "stop_lambda" {
  source           = "./modules/lambda_function"
  function_name    = "StopEC2Instances"
  handler_file     = "${path.module}/stop_lambda.py"
  handler_name     = "stop_lambda.lambda_handler"
  role_arn         = module.iam.lambda_role_arn
  environment_vars = {
    INSTANCE_IDS = "i-0169a79a8eb7421ef"
  }
}

module "start_schedule" {
  source              = "./modules/cloudwatch_event"
  rule_name           = "StartEC2InstancesRule"
  schedule_expr       = "cron(0 18 ? * MON-FRI *)" 
  lambda_function_arn = module.start_lambda.lambda_role_arn
}

module "stop_schedule" {
  source              = "./modules/cloudwatch_event"
  rule_name           = "StopEC2InstancesRule"
  schedule_expr       =  "cron(0 18 ? * MON-FRI *)" 
  lambda_function_arn = module.stop_lambda.lambda_role_arn
}