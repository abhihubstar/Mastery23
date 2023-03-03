data "aws_vpc" "myvpc" {
  filter {
    name   = "tag:Name"
    values = ["my-vpc"]
  }
}

data "aws_route53_zone" "selected" {
  name = format("%s.", var.domain)
}

data "aws_subnets" "mysubnets" {
  
  /* vpc_id = data.aws_vpc.myvpc.id */
  /* filter {
    name   = "tag:Name"
    values = ["application-tier"]
  } */
  tags = {
    Name = "my-vpc-public-*"
  }
}

/* data "aws_ssm_parameter" "ami" {
    name = "/aws/service/canonical/ubuntu/server/20.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
} */

/* resource "aws_key_pair" "this" {
  key_name = "deployer-key"
  public_key = "${file("${pathexpand("~")}/.ssh/my_rsa.pub")}"

  tags = merge(
    var.addl_tags,{})
} */


# Security Group for the ALB
resource "aws_security_group" "alb" {
  vpc_id = data.aws_vpc.myvpc.id    
  description = "SG for ALB, allows ingress from the internet"
  tags = merge(
    var.addl_tags,  
    {
      Name = "alb-sg"
  })
}

# Security Group for the ASG
resource "aws_security_group" "asg" {
  vpc_id = data.aws_vpc.myvpc.id
  description = "SG for ASG, allows ingress from the ALBs SG and SSH"
  tags = merge(
    var.addl_tags,  
    {
      Name = "scaling-group-sg"
  })
}

resource "aws_launch_template" "this" {
  instance_type = "t3.medium"
  image_id = "ami-0b029b1931b347543"
  /* key_name = aws_key_pair.this.key_name */

  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  network_interfaces {
    security_groups = [aws_security_group.asg.id]
  } 
  
  user_data = "${base64encode(file("${path.module}/user-data.sh"))}"
  tags = merge(
      var.addl_tags,
      {
          Name = "test-template"
      }
  )
}


resource "aws_lb" "this" {
  name = "webserver-lb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb.id]
  subnets = tolist(data.aws_subnets.mysubnets.ids)
  enable_http2 = false
  tags = var.addl_tags
}


resource "aws_lb_target_group" "this" {
  name = "webserver-lb-tg"
  port = 80
  protocol = "HTTP"
  vpc_id = data.aws_vpc.myvpc.id
}

resource "aws_autoscaling_group" "this" {
  max_size = 5
  min_size = 2
  health_check_grace_period = 300
  health_check_type = "ELB"
  desired_capacity = 2
  name_prefix = "webserver-"
  
  vpc_zone_identifier = tolist(data.aws_subnets.mysubnets.ids)
  launch_template {
    id = aws_launch_template.this.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.this.arn]

  /* tag = {
      var.addl_tags,
      {
          Name = "webserver-asg"
      }
  } */
  tag {
    key                 = "Name"
    value               = "webserver-asg"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.addl_tags

    content {
      key    =  tag.key
      value   =  tag.value
      propagate_at_launch =  true
    }
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port = "80"
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_route53_record" "route53" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = format("%s.%s", var.app_name, var.domain)
  type    = "CNAME"
  ttl     = var.timeToLive
  records = [aws_lb.this.dns_name]
}
