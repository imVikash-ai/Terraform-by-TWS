# create key-pair for ec2 instance
resource aws_key_pair my_key{
    key_name = "terra-key-ec2"
    public_key = file("terra-key-ec2.pub")

}

# VPC & Security Group
resource aws_default_vpc default {

}

resource aws_security_group my_security_group{
    name = "automate-sg"
    description= "this will add a TF generated security group"
    vpc_id = aws_default_vpc.default.id 

    tags = {
        Name = "automate-sg"
    }

    # inbound rules
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 8000
        to_port = 8000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # outbound rules
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# EC2 Instance
resource "aws_instance" "my-instance" {
    # count = 2  # meta-argument to create two instances
    for_each = tomap({
        instance-micro = "t2.micro"
        instance-medium = "t2.medium"
    })

    depends_on = [aws_security_group.my_security_group]

    key_name = aws_key_pair.my_key.key_name
    security_groups = [aws_security_group.my_security_group.name]
    instance_type = each.value
    ami = var.ec2_ami_id # Ubuntu AMI (HVM), SSD Volume Type
    root_block_device {
        volume_size = var.ec2_root_storage_size
        volume_type = "gp3"
    }
    tags = {
        Name = "each-key"
    }

  
}