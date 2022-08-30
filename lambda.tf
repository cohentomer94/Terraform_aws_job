
resource "aws_iam_role" "lambda_start_stop_ec2" {
  name = "lambda_stop_ec2"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lamdba_ec2_shutdown_policy" {
  name = "lamdba_ec2_shutdown_policy"
  role = "${aws_iam_role.lambda_start_stop_ec2.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Stop*",
        "ec2:terminate*",
		"ec2:DescribeInstances"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

data "archive_file" "zip" {
  type        = "zip"
  source_file = "lambda_stop_ec2.py"
  output_path = "lambda_stop_ec2.zip"
}

resource "aws_lambda_function" "lambda_stop_ec2" {
  filename         = "${data.archive_file.zip.output_path}"
  source_code_hash = "${data.archive_file.zip.output_base64sha256}"
  function_name    = "lambda_stop_ec2"
  timeout		   = 180  
  memory_size = 128 
  role             = "${aws_iam_role.lambda_start_stop_ec2.arn}"
  handler          = "lambda_stop_ec2.lambda_handler"
  runtime          = "python3.9"

}


resource "aws_cloudwatch_event_rule" "stop_ec2_event_rule" {
  name        = "stop-ec2-event-rule"
  description = "Stop running EC2 instance at a specified time each day"
  schedule_expression = "${var.schedule_expression}"

}

resource "aws_cloudwatch_event_target" "stop_ec2_event_rule_target" {
  rule      = "${aws_cloudwatch_event_rule.stop_ec2_event_rule.name}"
  target_id = "TriggerLambdaFunction"
  arn       = aws_lambda_function.lambda_stop_ec2.arn
  input 	= "{\"instance_id\":\"${aws_instance.web.id}\"}"
  }


resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_stop_ec2.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.stop_ec2_event_rule.arn
}
