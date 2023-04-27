output "ids" {
  value = tomap({
    for k, v in aws_security_group.main : k => v.id
  })
}