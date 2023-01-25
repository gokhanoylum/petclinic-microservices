variable "master-role-policy" {
  default = "petclinic_policy_for_master_role"
}

variable "worker-role-policy" {
  default = "petclinic_policy_for_worker_role"
}

variable "master-role" {
  default = "petclinic_role_master_k8s"
}

variable "worker-role" {
  default = "petclinic_role_worker_k8s"
}

variable "master-role-attachment" {
  default = "petclinic_attachment_for_master"
}

variable "worker-role-attachment" {
  default = "petclinic_attachment_for_worker"
}

variable "profile_for_master" {
  default = "petclinic_profile_for_master"
}

variable "profile_for_worker" {
  default = "petclinic_profile_for_worker"
}
```

- Create a terraform file for roles with the name of `roles.tf`  under the `infrastructure/dev-k8s-terraform/modules/IAM`.

```go
resource "aws_iam_policy" "policy_for_master_role" {
  name        = var.master-role-policy
  policy      = file("./modules/IAM/policy_for_master.json")
}

resource "aws_iam_policy" "policy_for_worker_role" {
  name        = var.worker-role-policy
  policy      = file("./modules/IAM/policy_for_worker.json")
}

resource "aws_iam_role" "role_for_master" {
  name = var.master-role

  # Terraform "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = "role_for_master"
  }
}

resource "aws_iam_role" "role_for_worker" {
  name = var.worker-role

  # Terraform "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = "role_for_worker"
  }
}

resource "aws_iam_policy_attachment" "attach_for_master" {
  name       = var.master-role-attachment
  roles      = [aws_iam_role.role_for_master.name]
  policy_arn = aws_iam_policy.policy_for_master_role.arn
}

resource "aws_iam_policy_attachment" "attach_for_worker" {
  name       = var.worker-role-attachment
  roles      = [aws_iam_role.role_for_worker.name]
  policy_arn = aws_iam_policy.policy_for_worker_role.arn
}

resource "aws_iam_instance_profile" "profile_for_master" {
  name  = var.profile_for_master
  role = aws_iam_role.role_for_master.name
}

resource "aws_iam_instance_profile" "profile_for_worker" {
  name  = var.profile_for_worker
  role = aws_iam_role.role_for_worker.name
}

output master_profile_name {
  value       = aws_iam_instance_profile.profile_for_master.name
}

output worker_profile_name {
  value       = aws_iam_instance_profile.profile_for_worker.name
}