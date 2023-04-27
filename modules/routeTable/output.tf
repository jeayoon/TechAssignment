output "ids" {
  value = tomap({
    for k, v in aws_route_table.main : k => v.id
  })
}