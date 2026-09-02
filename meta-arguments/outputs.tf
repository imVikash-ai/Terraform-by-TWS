# output "ec2_public_ip" {
#   value = aws_instance.my-instance[*].public_ip
  
# }
# output "ec2_public_dns" {
#   value = aws_instance.my-instance[*].public_dns
  
# }
# output "ec2_private_ip" {
#   value = aws_instance.my-instance[*].private_ip
  
# }
# output "ec2_private_dns" {
#   value = aws_instance.my-instance[*].private_dns
  
# }
output "ec2_public_ip" {
  value = [
    for key in aws_instance.my-instance : key.public_ip
  ]
}
output "ec2_private_ip" {
  value = [
    for key in aws_instance.my-instance : key.private_ip
  ]
}