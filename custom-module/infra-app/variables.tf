variable "env"{
    description = "This is the environment for the infra"
    type = string
}

variable "bucket_name"{
    description = "This is the bucket name for the infra"
    type = string
}

variable "instance_count"{
    description = "This is the number of EC2 instances to create"
    type = number
}

variable "instance_type"{
    description = "This is the number of EC2 instances to create"
    type = string
}

variable "ec2_ami_id"{
    description = "This is the AMI ID for the EC2 instances"
    type = string
}   

variable "hash_key"{
    description = "This is the hash key for the DynamoDB table"
    type = string
}