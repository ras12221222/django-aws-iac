resource "aws_iam_role" "this" {
  name               = var.role_name
  assume_role_policy = var.assume_role_policy
  description        = var.description
  tags               = var.tags
}

resource "aws_ssm_parameter" "iam_role" {
  name  = "/iam/${var.role_name}"
  type  = "String"
  value = aws_iam_role.this.arn
}

resource "aws_iam_policy" "inline" {
  for_each = var.inline_policy_json
  name   = "${var.role_name}-${each.key}-inline"
  policy = each.value
}

resource "aws_iam_role_policy_attachment" "managed" {
  for_each = toset(var.managed_policy_arns)
  role     = aws_iam_role.this.name
  policy_arn = each.value
}

resource "aws_iam_role_policy_attachment" "inline_attach" {
  for_each = aws_iam_policy.inline
  role       = aws_iam_role.this.name
  policy_arn = each.value.arn
}
