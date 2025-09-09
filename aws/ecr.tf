resource "aws_ecr_repository" "k8s_demo" {
  name = "k8s-demo-repo"
  image_tag_mutability = "MUTABLE"
}

# Use for pulling images into minikube. You will need to set up credentials in the AWS console
resource "aws_iam_user" "k8s_demo" {
  name = "k8s-demo"
}

resource "aws_iam_user_policy" "k8s_demo" {
  policy = data.aws_iam_policy_document.kds_demo.json
  user   = aws_iam_user.k8s_demo.id
}

data "aws_iam_policy_document" "kds_demo" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:GetAuthorizationToken"
    ]
    resources = [
      aws_ecr_repository.k8s_demo.arn
    ]
  }
}
