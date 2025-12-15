variable "name" {}
variable "ec2_url" {}

resource "aws_api_gateway_rest_api" "api" {
  name = var.name
}

resource "aws_api_gateway_resource" "resize" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "resize"
}

resource "aws_api_gateway_method" "post" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.resize.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "http" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.resize.id
  http_method             = aws_api_gateway_method.post.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "POST"
  uri                     = var.ec2_url
}

resource "aws_api_gateway_deployment" "deploy" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  depends_on  = [aws_api_gateway_integration.http]
  lifecycle { create_before_destroy = true }
}

resource "aws_api_gateway_stage" "stage" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "sandbox"
  deployment_id = aws_api_gateway_deployment.deploy.id
}

output "invoke_url" {
  value = "${aws_api_gateway_stage.stage.invoke_url}resize"
}
