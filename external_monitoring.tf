# External (off-network) uptime monitoring for public-facing services.
#
# Route53 health checks probe each endpoint from multiple AWS regions, so
# we get the internet's view rather than an in-cluster one (an in-cluster
# probe would have reported wiz6 healthy while it resolved to a private
# VIP). A CloudWatch alarm per check notifies an SNS topic, so the alert
# travels a path that does NOT depend on the cluster being reachable.
#
# Route53 health-check metrics are only published in us-east-1, which is
# the provider region, so the alarms live here too.

variable "alert_email" {
  description = "Email subscribed to external-monitoring alerts. AWS sends a confirmation email that must be clicked before alerts are delivered."
  type        = string
  default     = "alerts@goldentooth.net"
}

locals {
  # service key -> public FQDN to probe over HTTPS.
  monitored_services = {
    pds  = "pds.goldentooth.net"
    wiz6 = "wiz6.goldentooth.net"
  }
}

resource "aws_sns_topic" "external_monitoring" {
  name = "goldentooth-external-monitoring"
}

resource "aws_sns_topic_subscription" "external_monitoring_email" {
  topic_arn = aws_sns_topic.external_monitoring.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# One health check per service. AWS probes the FQDN over HTTPS from a
# global set of checker regions; 2xx/3xx responses are considered healthy.
# failure_threshold * request_interval (~90s) of failures flips it down.
resource "aws_route53_health_check" "service" {
  for_each = local.monitored_services

  type              = "HTTPS"
  fqdn              = each.value
  port              = 443
  resource_path     = "/"
  request_interval  = 30
  failure_threshold = 3
  measure_latency   = true

  tags = {
    Name = "goldentooth-${each.key}"
  }
}

# Alarm when the health check reports unhealthy for 3 consecutive minutes.
# HealthCheckStatus is 1 (healthy) / 0 (unhealthy); Minimum < 1 means at
# least one checker saw it down. treat_missing_data=breaching so a total
# metric outage is treated as an outage rather than silently ignored.
resource "aws_cloudwatch_metric_alarm" "service_health" {
  for_each = local.monitored_services

  alarm_name        = "external-${each.key}-unreachable"
  alarm_description = "Route53 health check for ${each.value} is failing from the public internet."

  namespace   = "AWS/Route53"
  metric_name = "HealthCheckStatus"
  dimensions = {
    HealthCheckId = aws_route53_health_check.service[each.key].id
  }

  statistic           = "Minimum"
  period              = 60
  evaluation_periods  = 3
  threshold           = 1
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "breaching"

  alarm_actions = [aws_sns_topic.external_monitoring.arn]
  ok_actions    = [aws_sns_topic.external_monitoring.arn]
}

output "external_monitoring_sns_topic_arn" {
  description = "SNS topic that receives external uptime alarm notifications."
  value       = aws_sns_topic.external_monitoring.arn
}
