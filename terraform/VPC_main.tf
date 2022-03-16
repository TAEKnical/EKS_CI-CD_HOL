# AWS Virtual Private Cloud

## Configures AWS provider


resource "aws_vpc" "vpc_main" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  assign_generated_ipv6_cidr_block = var.assign_generated_ipv6_cidr_block
  instance_tenancy = var.instance_tenancy
  tags = {
      Name = format(
        "%s-%s-VPC",
        var.company,
        var.environment
      )
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_main.id
  tags = {
      Name = format(
        "%s-%s-IGW",
        var.company,
        var.environment
      )
  }
}
# resource "aws_eip" "eip_for_nat" {
#   depends_on = [aws_route_table.public] 
#   count = local.nat_gateway_count 
#   tags = {
#     Name = format(
#       "%s-%s-NAT-%s",
#       var.company,
#       var.environment,
#       element(split("", local.public_subnets[count.index].zone), length(local.public_subnets[count.index].zone) - 1)
#     )
#   }
# }
# resource "aws_nat_gateway" "nat_gw" {
#   depends_on = [aws_eip.eip_for_nat] 
#   count = local.nat_gateway_count
#   allocation_id = aws_eip.eip_for_nat[count.index].id
#   subnet_id = aws_subnet.public[count.index].id
#   tags = {
#      Name = format(
#          "%s-%s-NAT-%s",
#          var.company,
#          var.environment,
#          element(split("", local.public_subnets[count.index].zone), length(local.public_subnets[count.index].zone) - 1)
#      )
#    }
# }
resource "aws_subnet" "public" {
  count             = length(local.public_subnets)
  vpc_id            = aws_vpc.vpc_main.id
  cidr_block        = local.public_subnets[count.index].cidr
  availability_zone = local.public_subnets[count.index].zone
  map_public_ip_on_launch = true
  tags = {
     Name = format(
         "%s-%s-%s-%s",
         var.company,
         var.environment,
         local.public_subnets[count.index].purpose,
         element(split("", local.public_subnets[count.index].zone), length(local.public_subnets[count.index].zone) - 1)
     )
     "kubernetes.io/role/elb" = "1"  # Refer: https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.1/deploy/subnet_discovery/
     "kubernetes.io/cluster/${var.cluster_name}" = "owned"
   }
}
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# resource "aws_subnet" "private" {
#   count             = length(local.private_subnets)
#   vpc_id            = aws_vpc.vpc_main.id
#   cidr_block        = local.private_subnets[count.index].cidr
#   availability_zone = local.private_subnets[count.index].zone
#   tags = {
#      Name = format(
#          "%s-%s-%s-%s",
#          var.company,
#          var.environment,
#          local.private_subnets[count.index].purpose,
#          element(split("", local.private_subnets[count.index].zone), length(local.private_subnets[count.index].zone) - 1)
#      )
#    }
# }
# resource "aws_route_table_association" "private" {
#   count = length(aws_subnet.private)
#   subnet_id      = aws_subnet.private[count.index].id
#   route_table_id  = element(
#     aws_route_table.private.*.id,
#     var.single_nat == true ? 1 : local.zone_index[element(split("", local.private_subnets[count.index].zone), length(local.private_subnets[count.index].zone) - 1)]
#   )
# }


resource "aws_route_table" "public" {
  depends_on = [aws_internet_gateway.igw] 
  lifecycle {
    # When attaching VPN gateways it is common to define aws_vpn_gateway_route_propagation
    # resources that manipulate the attributes of the routing table (typically for the private subnets)
    # ignore_changes = [propagating_vgws]
    ignore_changes = [route]
    # prevent_destroy = true
  }

  vpc_id = aws_vpc.vpc_main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  # route {
  #   cidr_block = "10.0.0.0/8" ## Private A CLASS
  #   transit_gateway_id = data.terraform_remote_state.CM_SECURITY_VPC.outputs.tgw
  # }
  # route {
  #   cidr_block = "172.16.0.0/12" ## Private B CLASS
  #   transit_gateway_id = data.terraform_remote_state.CM_SECURITY_VPC.outputs.tgw
  # }
  # route {
  #   cidr_block = "192.168.0.0/16" ## Private C CLASS
  #   transit_gateway_id = data.terraform_remote_state.CM_SECURITY_VPC.outputs.tgw
  # }
  
  tags = {
    Name = format(
        "%s-%s-rt-pub",
        var.company,
        var.environment
    )
  }
}

# resource "aws_route_table" "private" {
#   depends_on = [aws_nat_gateway.nat_gw]
#   lifecycle {
#     # When attaching VPN gateways it is common to define aws_vpn_gateway_route_propagation
#     # resources that manipulate the attributes of the routing table (typically for the private subnets)
#     # ignore_changes = [propagating_vgws]
#     ignore_changes = [route]
#     # prevent_destroy = true
#   }
  
#   count = length(aws_nat_gateway.nat_gw)
#   vpc_id = aws_vpc.vpc_main.id
#   route {
#     cidr_block = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.nat_gw[count.index].id
#   }
#   tags = {
#     Name = format(
#         "%s-%s-rt-pri-%s",
#         var.company,
#         var.environment,
#         element(split("", local.public_subnets[count.index].zone), length(local.public_subnets[count.index].zone) - 1)
#     )
#   }
# }