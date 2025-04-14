resource "aws_ecr_repository" "main" {
  name                 = "${var.environment}/${var.service_name}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = var.tags
}
