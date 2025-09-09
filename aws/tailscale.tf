resource "tailscale_tailnet_key" "vm_key" {
  reusable      = true
  ephemeral     = true
  preauthorized = true
  tags          = ["tag:k8s-demo"]
  description   = "VM bootstrap key"
}

data "aws_ami" "debian" {
  most_recent = true
  owners = ["aws-marketplace"]
  filter {
    name = "name"
    values = ["debian-12-*"]
  }
  filter {
    name = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_security_group" "tailscale_node" {
  vpc_id = module.vpc.vpc_id
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Unlimited so it can access Tailscale servers
  }
}

resource "aws_launch_template" "tailscale_node" {
  name_prefix  = "ts-node-"
  image_id = data.aws_ami.debian.id
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.tailscale_node.id]
  user_data = base64encode(templatefile("${path.module}/tailscale-data.sh", {
    auth_key = tailscale_tailnet_key.vm_key.key
    advertise_routes = join(",", module.vpc.private_subnets_cidr_blocks)
  }))
}

resource "aws_autoscaling_group" "tailscale_node" {
  max_size = 1
  min_size = 1
  vpc_zone_identifier = module.vpc.private_subnets
  launch_template {
    id = aws_launch_template.tailscale_node.id
    version = "$Latest"
  }
}
