output "ids" {
  value = tomap({
    for k, v in aws_subnet.main : k => v.id
  })
}