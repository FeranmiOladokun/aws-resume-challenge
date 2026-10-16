resource "aws_dynamodb_table" "aws-resume-test" {
  name         = "aws-resume-tf"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name        = "aws-resume-TF"
    Environment = "production"
  }
}

# IAM role for Lambda execution
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_iam_role" {
  name               = "lambda_role_tf"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Allow Lambda to update the counter table.
resource "aws_iam_role_policy" "counter_access" {
  name = "counter-table-access"
  role = aws_iam_role.lambda_iam_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "dynamodb:UpdateItem"
        Resource = aws_dynamodb_table.aws-resume-test.arn
      }
    ]
  })
}

# Allow Lambda to write execution logs to CloudWatch.
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Package the Lambda function code
data "archive_file" "example" {
  type        = "zip"
  source_file = "${path.module}/lambda/lambda_function.py"
  output_path = "${path.module}/lambda/function.zip"
}

# Lambda function
resource "aws_lambda_function" "mytf_function" {
  filename      = data.archive_file.example.output_path
  function_name = "mytf_function"
  role          = aws_iam_role.lambda_iam_role.arn
  handler       = "lambda_function.lambda_handler"
  code_sha256   = data.archive_file.example.output_base64sha256
  runtime       = "python3.14"

}

# Lambda function url
resource "aws_lambda_function_url" "myfunc_url" {
  function_name      = aws_lambda_function.mytf_function.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = true
    allow_origins     = ["https://www.resume.feminfo.xyz"]
    allow_methods     = ["GET"]
  }
}

