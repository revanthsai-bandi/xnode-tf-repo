locals {
  subnets = [aws_default_subnet.default_subnet_a.id, aws_default_subnet.default_subnet_b.id, aws_default_subnet.default_subnet_c.id]
}

resource "aws_elastic_beanstalk_application" "app" {
  name        = var.application
  description = "${var.application}-application"

  tags = {
    "stack_env" = var.environment
  }
}

resource "aws_elastic_beanstalk_application_version" "app" {
  name        = join("-",[aws_elastic_beanstalk_application.app.name,"version-label"])
  application = aws_elastic_beanstalk_application.app.name
  description = "application version created by terraform"
  bucket      = aws_s3_bucket.example.id
  key         = aws_s3_object.object.id
}

resource "aws_elastic_beanstalk_environment" "environment" {
  name                = "${var.application}-${var.environment}-env"
  application         = aws_elastic_beanstalk_application.app.name
  solution_stack_name = "64bit Amazon Linux 2023 v4.1.2 running Docker"
  version_label = aws_elastic_beanstalk_application_version.app.name
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    # value     = "arn:aws:iam::639834290217:role/service-role/aws-elasticbeanstalk-service-role"
    value = aws_iam_instance_profile.beanstalk_service.name
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = aws_default_vpc.default_vpc.id
  }

  # You need to define which subnets, unfortunately
  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", local.subnets)
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = join(",", local.subnets)
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBScheme"
    value     = "public"
  }
  # setting {
  # namespace = "aws:elbv2:listener:default"
  # name      = "ListenerEnabled"
  # value     = "false"
  # }

  # setting {
  # namespace = "aws:elbv2:listener:443"
  # name      = "ListenerEnabled"
  # value     = "true"
  # }

  # setting {
  # namespace = "aws:elbv2:listener:443"
  # name      = "Protocol"
  # value     = "HTTPS"
  # }

  # setting {
  # namespace = "aws:elbv2:listener:443"
  # name      = "SSLCertificateArns"
  # value     = var.ELB_certificate_arn
  # }

  # setting {
  # namespace = "aws:elbv2:listener:443"
  # name      = "SSLPolicy"
  # value     = var.sslpolicy
  # }

  # setting {
  # namespace = "aws:elb:policies"
  # name      = "ConnectionDrainingEnabled"
  # value     = "true"
  # }

  # setting {
  # namespace = "aws:elb:policies"
  # name      = "ConnectionDrainingTimeout"
  # value     = "30"
  # }

  # setting {
  # namespace = "aws:elb:policies"
  # name      = "ConnectionSettingIdleTimeout"
  # value     = "60"
  # }

  # setting {
  # namespace = "aws:elb:policies"
  # name      = "Stickiness Policy"
  # value     = "true"
  # }

  # setting {
  # namespace = "aws:elb:policies"
  # name      = "Stickiness Cookie Expiration"
  # value     = "300"
  # }

  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name      = "ConfigDocument"
    value = jsonencode({
      "CloudWatchMetrics" : {
        "Environment" : {
          "ApplicationRequestsTotal" : 60,
          "ApplicationRequests4xx" : 60,
          "ApplicationRequests5xx" : 60,
          "ApplicationLatencyP99.9" : 60
        },
        "Instance" : {
          "LoadAverage1min" : 60
        }
      },
      "Version" : 1
    })
    resource = ""
  }
  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "StreamLogs"
    value     = "false"
    resource  = ""
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "RetentionInDays"
    value     = 7
    resource  = ""
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "DeleteOnTerminate"
    value     = "false"
    resource  = ""
  }

  # setting {
  # namespace = "aws:elasticbeanstalk:customoption"
  # name      = "CloudWatchMetrics"
  # value     = "--mem-util --mem-used --mem-avail --disk-space-util --disk-space-used --disk-space-avail --disk-path=/ --auto-scaling"
  # resource  = ""
  #   }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "environment"
    value     = var.environment
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    # value     = "ec2-admin"
    value = aws_iam_instance_profile.beanstalk_ec2.name
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t2.micro"
  }
  setting {
    namespace = "aws:ec2:instances"
    name      = "EnableSpot"
    value     = "false"
  }
  setting {
    namespace = "aws:ec2:instances"
    name      = "InstanceTypes"
    value     = "t2.micro"
  }
  setting {
    namespace = "aws:ec2:instances"
    name      = "SupportedArchitectures"
    value     = "x86_64"
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = 1
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = 1
  }

  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name      = "SystemType"
    value     = "basic"
  }

  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name      = "HealthCheckSuccessThreshold"
    value     = "Ok"
  }
  #securitygroups

  # setting {
  # namespace = "aws:elbv2:loadbalancer"
  # name      = "SecurityGroups"
  # value     = module.security-group-elb.security_group_id
  # }
  # setting {
  #     namespace = "aws:autoscaling:launchconfiguration"
  #     name = "SecurityGroups"
  #     value = "sg-03cdb5d9f9e4835f1sg-09cdda7dd28d88d48"
  # }

  # Configure rolling deployments - begin
  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "DeploymentPolicy"
    value     = "AllAtOnce"
  }

  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "Timeout"
    value     = 600
  }


  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "BatchSizeType"
    value     = "percentage"
  }

  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "BatchSize"
    value     = 100
  }

  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "IgnoreHealthCheck"
    value     = "false"
  }
  # Configure rolling deployments - end

  # Configure rolling updates - begin
  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "RollingUpdateEnabled"
    value     = "false"
  }

  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "RollingUpdateType"
    value     = "Time"
  }

  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "MinInstancesInService"
    value     = 1
  }
  # Configure rolling updates - end

  # Configure managed updates - begin
  setting {
    namespace = "aws:elasticbeanstalk:managedactions"
    name      = "ManagedActionsEnabled"
    value     = "false"
  }

  # setting {
  # namespace = "aws:elasticbeanstalk:managedactions"
  # name      = "PreferredStartTime"
  # value     = var.preferred_start_time
  # }

  setting {
    namespace = "aws:elasticbeanstalk:managedactions:platformupdate"
    name      = "UpdateLevel"
    value     = "minor"
  }

  setting {
    namespace = "aws:elasticbeanstalk:managedactions:platformupdate"
    name      = "InstanceRefreshEnabled"
    value     = "false"
  }

  # setting {
  # namespace = "aws:elasticbeanstalk:application:environment"
  # name      = "dbhostname"
  # value     = aws_db_instance.this.address
  # }

  # ASG trigger for beanstalk

  # setting {
  # namespace = "aws:autoscaling:trigger"
  # name      = "MeasureName"
  # value     = var.autoscale_measure_name
  # resource  = ""
  # }

  # setting {
  # namespace = "aws:autoscaling:trigger"
  # name      = "Statistic"
  # value     = var.autoscale_statistic
  # resource  = ""
  # }

  # setting {
  # namespace = "aws:autoscaling:trigger"
  # name      = "Unit"
  # value     = var.autoscale_unit
  # resource  = ""
  # }

  # setting {
  # namespace = "aws:autoscaling:trigger"
  # name      = "LowerThreshold"
  # value     = var.autoscale_lower_bound
  # resource  = ""
  # }

  # setting {
  # namespace = "aws:autoscaling:trigger"
  # name      = "LowerBreachScaleIncrement"
  # value     = var.autoscale_lower_increment
  # resource  = ""
  # }

  # setting {
  # namespace = "aws:autoscaling:trigger"
  # name      = "UpperThreshold"
  # value     = var.autoscale_upper_bound
  # resource  = ""
  # }

  # setting {
  # namespace = "aws:autoscaling:trigger"
  # name      = "UpperBreachScaleIncrement"
  # value     = var.autoscale_upper_increment
  # resource  = ""
  # }
  setting {
    namespace = "aws:elasticbeanstalk:environment:proxy"
    name      = "ProxyServer"
    value     = "nginx"
  }
  // Will enable it once approved by security
  //  lifecycle {
  //    ignore_changes = [
  //      setting,
  //    ]
  //  }

  tags = {
    # "stack"     = var.stack
    "stack_env"   = var.environment
    "application" = var.application
  }
}