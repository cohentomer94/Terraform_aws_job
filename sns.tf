resource "aws_cloudwatch_event_target" "sns_target" {
  arn = aws_sns_topic.sns_alarm.arn
  rule = aws_cloudwatch_event_rule.stop_ec2_event_rule.name
  target_id = "send-sns-notification"
}


resource "aws_sns_topic" "sns_alarm" {
  name = "user-updates-topic"
}

resource "aws_sns_topic_subscription" "sns-topic" {
  topic_arn = aws_sns_topic.sns_alarm.arn
  protocol  = "email"
  endpoint  = "${var.mail_sns}"
}


resource "aws_cloudwatch_event_rule" "publish-sns-rule" {
  name = "publish-sns-rule"
  schedule_expression = "${var.schedule_expression}"
  event_pattern = <<PATTERN
    {
    "who": ["Peter"],
    "message_part_1": ["ec2_over_9_hours"]
 }
PATTERN
}

resource "aws_cloudwatch_event_target" "sns-publish" {
  count = "1"
  rule = aws_cloudwatch_event_rule.publish-sns-rule.name
  target_id = aws_sns_topic.sns_alarm.name
  arn = aws_sns_topic.sns_alarm.arn
}


resource "aws_sns_topic_policy" "default" {
  count  = 1
  arn    = aws_sns_topic.sns_alarm.arn
  policy = "${data.aws_iam_policy_document.sns_topic_policy.0.json}"
}

data "aws_iam_policy_document" "sns_topic_policy" {
  count = "1"
  statement {
    sid       = "Allow CloudwatchEvents"
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.sns_alarm.arn]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}