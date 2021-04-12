
resource "aws_iam_role" "lambda_counter_role" {
  name = "lambda_counter_role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_counter_policy" {
  name = "lambda_counter_policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "0",
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:GetItem",
          "dynamodb:PutItem"
        ],
        "Resource" : aws_dynamodb_table.counter_table.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_counter_attachement" {
  role       = aws_iam_role.lambda_counter_role.name
  policy_arn = aws_iam_policy.lambda_counter_policy.arn
}

resource "aws_lambda_function" "lambda_counter" {
  filename      = "../lambda_counter.zip"
  function_name = "lambda_counter"
  role          = aws_iam_role.lambda_counter_role.arn
  handler       = "lambda_function.lambda_handler"

  source_code_hash = filebase64sha256("../lambda_counter.zip")

  runtime = "python3.8"

  depends_on = [aws_iam_role_policy_attachment.lambda_counter_attachement]
}
