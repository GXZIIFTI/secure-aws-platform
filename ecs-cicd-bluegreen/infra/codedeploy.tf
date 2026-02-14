data "aws_iam_policy_document" "codedeploy_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codedeploy_role" {
  name               = "${var.project_name}-codedeploy-role"
  assume_role_policy = data.aws_iam_policy_document.codedeploy_assume.json
}

data "aws_iam_policy_document" "codedeploy_extra_ecs" {
  statement {
    sid = "AllowDescribeECSServiceForBlueGreen"

    actions = [
      "ecs:DescribeServices",
      "ecs:DescribeTaskDefinition",
      "ecs:DescribeClusters",
      "ecs:ListServices",
      "ecs:ListTasks",
      "ecs:DescribeTasks"
    ]

    resources = ["*"]
  }

  statement {
    sid = "AllowELBReadForTargetGroups"

    actions = [
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetHealth",
      "elasticloadbalancing:DescribeLoadBalancers"
    ]

    resources = ["*"]
  }

  statement {
    sid = "AllowCloudWatchAlarmRead"
    actions = [
      "cloudwatch:DescribeAlarms",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:ListMetrics"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "codedeploy_extra_ecs" {
  name   = "${var.project_name}-codedeploy-extra"
  role   = aws_iam_role.codedeploy_role.id
  policy = data.aws_iam_policy_document.codedeploy_extra_ecs.json
}


resource "aws_iam_role_policy_attachment" "codedeploy_attach" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn  = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

resource "aws_codedeploy_app" "ecs" {
  name             = "${var.project_name}-codedeploy-app"
  compute_platform = "ECS"
}

resource "aws_codedeploy_deployment_group" "ecs" {
  app_name               = aws_codedeploy_app.ecs.name
  deployment_group_name  = "${var.project_name}-dg"
  service_role_arn       = aws_iam_role.codedeploy_role.arn
  deployment_config_name = "CodeDeployDefault.ECSCanary10Percent5Minutes"

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  blue_green_deployment_config {
    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }

    deployment_ready_option {
      action_on_timeout    = "CONTINUE_DEPLOYMENT"
      wait_time_in_minutes = 0
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE", "DEPLOYMENT_STOP_ON_ALARM", "DEPLOYMENT_STOP_ON_REQUEST"]
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.this.name
    service_name = aws_ecs_service.app.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.http.arn]
      }

      target_group {
        name = aws_lb_target_group.app_tg_blue.name
      }

      target_group {
        name = aws_lb_target_group.app_tg_green.name
      }
    }
  }
}
