variable "ec2_instance_type" {
    default = "t3.micro"
    type = string
  
}

variable "ec2_default_root_storage_size" {
    default = 10
    type = number
}
variable "ec2_ami_id" {
    default = "ami-0e5497a77ef21b5ac"
    type = string
}

variable "env"{
    default = "prod"
    type = string
}