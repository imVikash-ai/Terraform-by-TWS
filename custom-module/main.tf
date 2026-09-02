module "dev-infra"{
    source = "./infra-app"
    env = "dev"
    bucket_name = "infra-app-bucket"
    instance_count = 1
    instance_type = "t3.micro"
    ec2_ami_id = "ami-0b6d9d3d33ba97d99" # Ubuntu AMI (HVM), SSD Volume Type
    hash_key = "StudentId"
}