output "id" {
    value       = aws_vpc.main.id
    description = "VPC ID"
}
output "cidr_block" {
    value       = aws_vpc.main.cidr_block
    description = "VPC ID"
}
output "ipv6_cidr_block" {
    value       = aws_vpc.main.ipv6_cidr_block
    description = "VPC ID"
}