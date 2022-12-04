resource "random_uuid" "this" {
}

# resource "random_id" "server" {
#   keepers = {
#     # Generate a new id each time we switch to a new AMI id
#     ami_id = var.ami_id
#   }

#   byte_length = 8
# }

// create a unuqiue name each time to overcome bug with snowflake
resource "aws_sns_topic" "this" {
  name            = "topic-${local.bucket_name}-${random_uuid.this.result}"
  delivery_policy = <<EOF
  {
    "http": {
      "defaultHealthyRetryPolicy": {
        "minDelayTarget": 20,
        "maxDelayTarget": 20,
        "numRetries": 3,
        "numMaxDelayRetries": 0,
        "numNoDelayRetries": 0,
        "numMinDelayRetries": 0,
        "backoffFunction": "linear"
      },
      "disableSubscriptionOverrides": false,
      "defaultThrottlePolicy": {
        "maxReceivesPerSecond": 1
      }
    }
  }
  EOF

  tags = var.stack_context["tags"]
}

// Creates policy to attach to the SNS topic
data "aws_iam_policy_document" "sns_topic_policy" {
  policy_id = "__default_policy_ID"

  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        data.aws_caller_identity.current.account_id,
      ]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      aws_sns_topic.this.arn
    ]

    sid = "__default_statement_ID"
  }

  statement {
    actions = [
      "SNS:Subscribe"
    ]
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [snowflake_storage_integration.this.storage_aws_iam_user_arn]
    }

    resources = [
      aws_sns_topic.this.arn,
    ]

    sid = "1"
  }

  statement {
    actions = [
      "SNS:Publish"
    ]

    condition {
      test     = "ArnLike"
      variable = "AWS:SourceArn"
      values = [
        aws_s3_bucket.this.arn
      ]
    }

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    resources = [
      aws_sns_topic.this.arn,
    ]

    sid = "s3-event-notifier"
  }
}

// Attaches the policy to SNS topic
resource "aws_sns_topic_policy" "default" {
  arn    = aws_sns_topic.this.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}
