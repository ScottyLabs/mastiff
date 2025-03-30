output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.instance.id
}

output "public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.instance.public_ip
}

output "private_ip" {
  description = "The private IP address of the EC2 instance"
  value       = aws_instance.instance.private_ip
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.security_group.id
}

output "iam_role_name" {
  description = "The name of the IAM role"
  value       = aws_iam_role.instance_role.name
}

output "iam_role_arn" {
  description = "The ARN of the IAM role"
  value       = aws_iam_role.instance_role.arn
}

output "instance_profile_name" {
  description = "The name of the instance profile"
  value       = aws_iam_instance_profile.instance_profile.name
}
