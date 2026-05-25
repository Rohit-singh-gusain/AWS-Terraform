resource "aws_sns_topic" "cpu_alert_topic" {
  name = "ec2-cpu-alert-topic"

  tags = {
    Name        = "EC2 CPU Alert Topic"
    Environment = var.env
    ManagedBy   = "Terraform"
  }
}

resource "aws_sns_topic_subscription" "cpu_alert_email" {
  topic_arn = aws_sns_topic.cpu_alert_topic.arn
  protocol  = "email"             
  endpoint  = var.EMAIL    
}


resource "aws_cloudwatch_metric_alarm" "cpu_critical" {
  count = length(var.ec2_ids)
  alarm_name        = "ec2-cpu-critical-${var.ec2_ids[count.index]}"
  alarm_description = "CRITICAL: EC2 CPU above 90% — immediate action needed"

  namespace   = "AWS/EC2"
  metric_name = "CPUUtilization"
  dimensions = {
    InstanceId =  var.ec2_ids[count.index]
  }

  period              = 300
  statistic           = "Average"
  comparison_operator = "GreaterThanThreshold"
  threshold           = 90         # higher threshold for critical alert

  # Only needs 1 out of 1 — alert immediately, no waiting
  evaluation_periods  = 1
  datapoints_to_alarm = 1

  alarm_actions      = [aws_sns_topic.cpu_alert_topic.arn]
  ok_actions         = [aws_sns_topic.cpu_alert_topic.arn]
  treat_missing_data = "notBreaching"

  tags = {
    Name        = "EC2 CPU Critical Alarm"
    Environment = var.env
    ManagedBy   = "Terraform"
  }
}