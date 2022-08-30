resource "aws_wafv2_web_acl" "my_waf" {
  name        = "managed-rule-example"
  description = "Example of a managed rule."
  scope = "REGIONAL"

  default_action {
    allow {}
  }
/* 
    insert_header{
    name = "X-Origin-Header"
    values = "111"
    } */
    

  rule {
    name     = "rule-1"
    priority = 1

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"


        excluded_rule {
          name = "SizeRestrictions_QUERYSTRING"
        }

        excluded_rule {
          name = "NoUserAgent_HEADER"
          




        }

        scope_down_statement {
          geo_match_statement {
            country_codes = ["US", "NL"]
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "friendly-rule-metric-name"
      sampled_requests_enabled   = false
    }
  }

  tags = {
    Tag1 = "Value1"
    Tag2 = "Value2"
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "friendly-metric-name"
    sampled_requests_enabled   = false
  }
}

resource "aws_wafv2_web_acl_association" "main" {
  count = 1
  resource_arn = aws_alb.my_api.arn
  web_acl_arn  = aws_wafv2_web_acl.my_waf.arn

  depends_on = [aws_wafv2_web_acl.my_waf]
}