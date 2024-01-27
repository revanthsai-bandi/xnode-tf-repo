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
  solution_stack_name = "64bit Amazon Linux 2023 v4.2.0 running Docker"
  version_label = aws_elastic_beanstalk_application_version.app.name
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value = aws_iam_role.beanstalk_service.name
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = aws_default_vpc.default_vpc.id
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", local.subnets)
  }
  setting {
  namespace = "aws:autoscaling:asg"
  name = "Availability Zones"
  value = "Any"
}
setting {
  namespace = "aws:autoscaling:asg"
  name = "Cooldown"
  value = 360
}
setting {
  namespace = "aws:autoscaling:asg"
  name = "EnableCapacityRebalancing"
  value = false
}
setting {
  namespace = "aws:autoscaling:asg"
  name = "MaxSize"
  value = 1
}
setting {
  namespace = "aws:autoscaling:asg"
  name = "MinSize"
  value = 1
}
setting {
  namespace = "aws:autoscaling:launchconfiguration"
  name = "DisableIMDSv1"
  value = true
}
setting {
  namespace = "aws:autoscaling:launchconfiguration"
  name = "EC2KeyName"
  # value = "us-east2-key-pair"
  value = module.key_pair.key_pair_name
}
setting {
  namespace = "aws:autoscaling:launchconfiguration"
  name = "IamInstanceProfile"
  value = aws_iam_instance_profile.beanstalk_ec2.name
}
setting {
  namespace = "aws:autoscaling:launchconfiguration"
  name = "InstanceType"
  value = "t2.micro"
}
setting {
  namespace = "aws:autoscaling:launchconfiguration"
  name = "MonitoringInterval"
  value = "5 minute"
}
setting {
  namespace = "aws:autoscaling:updatepolicy:rollingupdate"
  name = "RollingUpdateEnabled"
  value = false
}
setting {
  namespace = "aws:autoscaling:updatepolicy:rollingupdate"
  name = "RollingUpdateType"
  value = "Time"
}
setting {
  namespace = "aws:autoscaling:updatepolicy:rollingupdate"
  name = "Timeout"
  value = "PT30M"
}
setting {
  namespace = "aws:cloudformation:template:parameter"
  name = "InstancePort"
  value = 80
}
setting {
  namespace = "aws:cloudformation:template:parameter"
  name = "InstanceTypeFamily"
  value = "t2"
}
setting {
  namespace = "aws:ec2:instances"
  name = "EnableSpot"
  value = false
}
setting {
  namespace = "aws:ec2:instances"
  name = "InstanceTypes"
  value = "t2.micro"
}
setting {
  namespace = "aws:ec2:instances"
  name = "SpotFleetOnDemandAboveBasePercentage"
  value = 0
}
setting {
  namespace = "aws:ec2:instances"
  name = "SpotFleetOnDemandBase"
  value = 0
}
setting {
  namespace = "aws:ec2:instances"
  name = "SupportedArchitectures"
  value = "x86_64"
}
setting {
  namespace = "aws:ec2:vpc"
  name = "AssociatePublicIpAddress"
  value = false
}
setting {
  namespace = "aws:ec2:vpc"
  name = "ELBScheme"
  value = "public"
}
setting {
  namespace = "aws:elasticbeanstalk:cloudwatch:logs"
  name = "DeleteOnTerminate"
  value = false
}
setting {
  namespace = "aws:elasticbeanstalk:cloudwatch:logs"
  name = "RetentionInDays"
  value = 7
}
setting {
  namespace = "aws:elasticbeanstalk:cloudwatch:logs"
  name = "StreamLogs"
  value = false
}
setting {
  namespace = "aws:elasticbeanstalk:cloudwatch:logs:health"
  name = "DeleteOnTerminate"
  value = false
}
setting {
  namespace = "aws:elasticbeanstalk:cloudwatch:logs:health"
  name = "HealthStreamingEnabled"
  value = false
}
setting {
  namespace = "aws:elasticbeanstalk:cloudwatch:logs:health"
  name = "RetentionInDays"
  value = 7
}
setting {
  namespace = "aws:elasticbeanstalk:command"
  name = "BatchSize"
  value = 100
}
setting {
  namespace = "aws:elasticbeanstalk:command"
  name = "BatchSizeType"
  value = "Percentage"
}
setting {
  namespace = "aws:elasticbeanstalk:command"
  name = "DeploymentPolicy"
  value = "AllAtOnce"
}
setting {
  namespace = "aws:elasticbeanstalk:command"
  name = "IgnoreHealthCheck"
  value = false
}
setting {
  namespace = "aws:elasticbeanstalk:command"
  name = "Timeout"
  value = 600
}
setting {
  namespace = "aws:elasticbeanstalk:control"
  name = "DefaultSSHPort"
  value = 22
}
setting {
  namespace = "aws:elasticbeanstalk:control"
  name = "LaunchTimeout"
  value = 0
}
setting {
  namespace = "aws:elasticbeanstalk:control"
  name = "LaunchType"
  value = "Migration"
}
setting {
  namespace = "aws:elasticbeanstalk:control"
  name = "RollbackLaunchOnFailure"
  value = false
}
setting {
  namespace = "aws:elasticbeanstalk:environment"
  name = "EnvironmentType"
  value = "SingleInstance"
}
setting {
  namespace = "aws:elasticbeanstalk:environment:proxy"
  name = "ProxyServer"
  value = "nginx"
}
setting {
  namespace = "aws:elasticbeanstalk:healthreporting:system"
  name = "EnhancedHealthAuthEnabled"
  value = false
}
setting {
  namespace = "aws:elasticbeanstalk:healthreporting:system"
  name = "HealthCheckSuccessThreshold"
  value = "Ok"
}
setting {
  namespace = "aws:elasticbeanstalk:healthreporting:system"
  name = "SystemType"
  value = "basic"
}
setting {
  namespace = "aws:elasticbeanstalk:hostmanager"
  name = "LogPublicationControl"
  value = false
}
setting {
  namespace = "aws:elasticbeanstalk:managedactions"
  name = "ManagedActionsEnabled"
  value = false
}
setting {
  namespace = "aws:elasticbeanstalk:managedactions:platformupdate"
  name = "InstanceRefreshEnabled"
  value = false
}
setting {
  namespace = "aws:elasticbeanstalk:managedactions:platformupdate"
  name = "UpdateLevel"
  value = "minor"
}
setting {
  namespace = "aws:elasticbeanstalk:monitoring"
  name = "Automatically Terminate Unhealthy Instances"
  value = true
}
# setting {
#   namespace = "aws:elasticbeanstalk:sns:topics"
#   name = "Notification Protocol"
#   value = "email"
# }
setting {
  namespace = "aws:elasticbeanstalk:xray"
  name = "XRayEnabled"
  value = false
}
setting {
  namespace = "aws:rds:dbinstance"
  name = "HasCoupledDatabase"
  value = false
 }
 
}