data "tls_certificate" "github_actions" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github_actions.certificates[0].sha1_fingerprint]
}

data "aws_iam_policy_document" "github_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Only allow this repo + branch
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_org_repo}:ref:refs/heads/${var.github_branch}"]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = "${var.project_name}-github-actions"
  assume_role_policy = data.aws_iam_policy_document.github_assume.json
}

data "aws_iam_policy_document" "github_actions_policy" {
  # ECR push
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
      "ecr:BatchGetImage",
      "ecr:DescribeRepositories"
    ]
    resources = ["*"]
  }

  # Register task definition
  statement {
    actions = [
      "ecs:RegisterTaskDefinition",
      "ecs:DescribeTaskDefinition"
    ]
    resources = ["*"]
  }

  # CodeDeploy
  statement {
    actions = [
      "codedeploy:CreateDeployment",
      "codedeploy:GetDeployment",
      "codedeploy:GetDeploymentGroup",
      "codedeploy:ListDeployments"
    ]
    resources = ["*"]
  }

  # S3 (AppSpec revisions)
  statement {
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${var.codedeploy_bucket}"]
  }

  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion"
    ]
    resources = ["arn:aws:s3:::${var.codedeploy_bucket}/*"]
  }

  # Pass ECS execution role
  statement {
    actions   = ["iam:PassRole"]
    resources = [aws_iam_role.ecs_task_execution.arn]
  }
}

resource "aws_iam_role_policy" "github_actions_inline" {
  name   = "${var.project_name}-github-actions-inline"
  role   = aws_iam_role.github_actions.id
  policy = data.aws_iam_policy_document.github_actions_policy.json
}
