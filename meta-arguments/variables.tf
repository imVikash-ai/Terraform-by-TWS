variable "ec2_instance_type" {
    default = "t3.micro"
    type = string
  
}

variable "ec2_root_storage_size" {
    default = 8
    type = number
}
variable "ec2_ami_id" {
    default = "ami-0e5497a77ef21b5ac"
    type = string
}
