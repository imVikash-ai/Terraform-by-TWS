# create key-pair for ec2 instance
resource aws_key_pair my_key{
    key_name = "${var.env}-infra-app-key"
    public_key = file("terra-key-ec2.pub")

    tags = {
        Environment = var.env
    }
}

# VPC & Security Group
resource aws_default_vpc default {

}

resource aws_security_group my_security_group{
    name = "${var.env}-infra-app-sg"
    description= "this will add a TF generated security group"
    vpc_id = aws_default_vpc.default.id 

    tags = {
        Name = "${var.env}-infra-app-sg"
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
    count = var.instance_count
    key_name = aws_key_pair.my_key.key_name
    security_groups = [aws_security_group.my_security_group.name]
    instance_type = var.instance_type
    ami = var.ec2_ami_id # Ubuntu AMI (HVM), SSD Volume Type
    root_block_device {
        volume_size = var.env == "prod" ? 20 : 10
        volume_type = "gp3"
    }
    tags = {
        Name = "${var.env}-infra-app-instance"
    }

  
}