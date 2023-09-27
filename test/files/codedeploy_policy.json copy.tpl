{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowLoadBalancingAndECSModifications",
            "Effect": "Allow",
            "Resource": [
                "*"
            ],
            "Action": [
                "ecs:CreateTaskSet",
                "ecs:DeleteTaskSet",
                "ecs:DescribeServices",
                "ecs:UpdateServicePrimaryTaskSet",
                "elasticloadbalancing:DescribeListeners",
                "elasticloadbalancing:DescribeRules",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:ModifyListener",
                "elasticloadbalancing:ModifyRule",
                "s3:GetObject"
            ]
        },
        {
            "Sid": "DeployService",
            "Effect": "Allow",
            "Resource": [
                "${aws_ecs_service_id}",
                "${aws_codedeploy_deployment_group_arn}",
                "${aws_codedeploy_app_arn}",
                "arn:aws:codedeploy:${region}:${account_id}:deploymentconfig:*"
            ],
            "Action": [
                "ecs:DescribeServices",
                "codedeploy:GetDeploymentGroup",
                "codedeploy:CreateDeployment",
                "codedeploy:GetDeployment",
                "codedeploy:GetDeploymentConfig",
                "codedeploy:RegisterApplicationRevision"
            ]
        },
        {
            "Sid": "AllowPassRole",
            "Effect": "Allow",
            "Resource": [
                "${execution_role_arn}"
            ],
            "Action": [
                "iam:PassRole"
            ]
        }
    ]
}