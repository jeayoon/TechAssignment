output "ids" {
  value = tomap({
    for k, v in aws_ssm_parameter.main : k => v.id
  })
}