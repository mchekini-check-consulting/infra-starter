resource "aws_api_gateway_rest_api" "sm-apigw" {
  name        = "sm-apigw"
  description = "API Gateway for Staff Manager Application"
}

resource "aws_api_gateway_resource" "sm-resource-api" {
  rest_api_id = aws_api_gateway_rest_api.sm-apigw.id
  parent_id   = aws_api_gateway_rest_api.sm-apigw.root_resource_id
  path_part   = "api"
}

resource "aws_api_gateway_resource" "sm-resource-version" {
  rest_api_id = aws_api_gateway_rest_api.sm-apigw.id
  parent_id   = aws_api_gateway_resource.sm-resource-api.id
  path_part   = "v1"
}