# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "aws" {
}


# Creates a role for the AWS Secrets Engine to assume for the sessions it generates. These are the permissions that you will 
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "tfc_role" {
  name = "tfc-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_iam_user.secrets_engine.arn}"
            },
            "Action": "sts:AssumeRole",
            "Condition": {}
        }
    ]
}
EOF
}

# Creates a policy that will be used to define the permissions that
# the previously created role has within AWS. These are the permissions
# that runs within the TFC workspace will use.
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy
resource "aws_iam_policy" "tfc_policy" {
  name        = "tfc-policy"
  description = "TFC run policy"

  policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Effect": "Allow",
     "Action": [
       "s3:ListBucket"
     ],
     "Resource": "*"
   }
 ]
}
EOF
}

# Creates an attachment to associate the above policy with the
# previously created role.
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
resource "aws_iam_role_policy_attachment" "tfc_policy_attachment" {
  role       = aws_iam_role.tfc_role.name
  policy_arn = aws_iam_policy.tfc_policy.arn
}


# Provides an IAM user.
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user
resource "aws_iam_user" "secrets_engine" {
  name = "hcp-vault-secrets-engine"
}

# Provides an IAM access key. This is a set of credentials that allow API requests to be made as an IAM user.
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key
resource "aws_iam_access_key" "secrets_engine_credentials" {
  # WARNING - The credentials this resource generateds will be written in plaintext in the statefiles for this configuration.
  # Protect the statefiles for this configuration accordingly!
  user = aws_iam_user.secrets_engine.name
}


# Provides an IAM policy attached to a user. In this case, allowing the secrets_engine user to assume other roles via STS
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy
resource "aws_iam_user_policy" "vault_secrets_engine_generate_credentials" {
  name = "hcp-vault-secrets-engine-policy"
  user = aws_iam_user.secrets_engine.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
        ]
        Effect   = "Allow"
        Resource = "${aws_iam_role.tfc_role.arn}"
      },
    ]
  })
}